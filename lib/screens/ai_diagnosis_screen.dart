import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';

/// Shared dark/light hybrid theme tokens — kept in sync with home_screen.dart.
class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A);
  static const mistLavender = Color(0xFF8FA6FF);
  static const aiViolet = Color(0xFFB388FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillHover = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const glassHighlight = Color(0x4DFFFFFF);
  static const textOnDark = Colors.white;
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

/// AI Vehicle Diagnosis screen.
/// User picks a common symptom, types their own, speaks it via the mic
/// button, or photographs a dashboard warning light. Text problems are
/// sent to `ai_diagnosis.php`; warning-light photos are sent to
/// `analyze_dashboard.php`. Both call the Gemini API and return a
/// structured diagnosis (cause, safety advice, drivability, severity,
/// next step, estimated repair cost). Every diagnosis is also saved
/// server-side in the `ai_diagnosis` table for history.
class AiDiagnosisScreen extends StatefulWidget {
  const AiDiagnosisScreen({super.key});

  @override
  State<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}

class _AiDiagnosisScreenState extends State<AiDiagnosisScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  // ---- Voice input state ----
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  // ---- Image input state ----
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _quickPrompts = const [
    "Car won't start",
    'Battery warning light is on',
    'Engine overheating',
    'Strange engine noise',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is not available on this device.')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _pickWarningLightImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceSheet(),
    );

    if (source == null) return;

    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (picked == null) return;

    await _analyzeWarningLightImage(picked);
  }

  Future<void> _analyzeWarningLightImage(XFile image) async {
    if (_isThinking) return;

    setState(() {
      _messages.add(_ChatMessage(text: '', isUser: true, imagePath: image.path));
      _isThinking = true;
    });

    final user = await SessionManager.getUserDetails();
    final userId = user["user_id"];

    final result = await ApiService.analyzeDashboardImage(
      userId: userId,
      imagePath: image.path,
    );

    if (!mounted) return;

    setState(() {
      _isThinking = false;

      if (result["success"] == true && result["diagnosis"] != null) {
        final d = result["diagnosis"];
        _messages.add(_ChatMessage(
          text: '',
          isUser: false,
          diagnosis: _Diagnosis(
            warningLightIdentified: d["warning_light_identified"]?.toString(),
            possibleCause: (d["possible_cause"] ?? 'Not determined').toString(),
            safetyAdvice: (d["safety_advice"] ?? '').toString(),
            canBeDriven: (d["can_be_driven"] ?? 'No').toString().trim().toLowerCase() == 'yes',
            severity: (d["severity"] ?? 'Medium').toString(),
            nextStep: (d["recommended_next_step"] ?? '').toString(),
            estimatedCost: (d["estimated_repair_cost"] ?? 'Not available').toString(),
          ),
        ));
      } else {
        _messages.add(_ChatMessage(
          text: '',
          isUser: false,
          errorText: result["message"]?.toString() ??
              "Couldn't reach the diagnosis service. Please try again.",
        ));
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isThinking) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isThinking = true;
      _controller.clear();
    });

    final user = await SessionManager.getUserDetails();
    final userId = user["user_id"];

    final result = await ApiService.getAiDiagnosis(
      userId: userId,
      userMessage: text,
    );

    if (!mounted) return;

    setState(() {
      _isThinking = false;

      if (result["success"] == true && result["diagnosis"] != null) {
        final d = result["diagnosis"];
        _messages.add(_ChatMessage(
          text: '',
          isUser: false,
          diagnosis: _Diagnosis(
            possibleCause: (d["possible_cause"] ?? 'Not determined').toString(),
            safetyAdvice: (d["safety_advice"] ?? '').toString(),
            canBeDriven: (d["can_be_driven"] ?? 'No').toString().trim().toLowerCase() == 'yes',
            severity: (d["severity"] ?? 'Medium').toString(),
            nextStep: (d["recommended_next_step"] ?? '').toString(),
            estimatedCost: (d["estimated_repair_cost"] ?? 'Not available').toString(),
          ),
        ));
      } else {
        _messages.add(_ChatMessage(
          text: '',
          isUser: false,
          errorText: result["message"]?.toString() ??
              "Couldn't reach the diagnosis service. Please try again.",
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(Icons.psychology_alt_outlined, color: _RRColors.aiViolet, size: 20),
            const SizedBox(width: 8),
            const Text(
              'AI Diagnosis',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48), // clears the transparent app bar
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return const _ThinkingBubble();
                          }
                          final msg = _messages[index];
                          if (msg.isUser) {
                            return msg.imagePath != null
                                ? _UserImageBubble(imagePath: msg.imagePath!)
                                : _UserBubble(text: msg.text);
                          }
                          if (msg.diagnosis != null) return _DiagnosisBubble(diagnosis: msg.diagnosis!);
                          return _ErrorBubble(text: msg.errorText ?? 'Something went wrong.');
                        },
                      ),
              ),
              if (_isListening) _buildListeningBanner(),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListeningBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.emergencyRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Listening...',
            style: TextStyle(fontSize: 12, color: _RRColors.textMutedOnDark, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _RRColors.aiViolet.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _RRColors.aiViolet.withValues(alpha: 0.3), blurRadius: 18),
              ],
            ),
            child: const Icon(Icons.psychology_alt_outlined, color: _RRColors.aiViolet, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            "Tell me what's wrong with your vehicle",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'This is guidance only — not a replacement\nfor a professional inspection.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _RRColors.textMutedOnDark),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _quickPrompts.map((p) {
              return _QuickPromptChip(label: p, onTap: () => _sendMessage(p));
            }).toList(),
          ),
          const SizedBox(height: 16),
          _QuickPromptChip(
            label: '📷 Photograph a warning light',
            onTap: _pickWarningLightImage,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: _RRColors.textMutedOnDark),
            onPressed: _isThinking ? null : _pickWarningLightImage,
            tooltip: 'Photograph a dashboard warning light',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _sendMessage,
              style: const TextStyle(color: Colors.white),
              cursorColor: _RRColors.aiViolet,
              decoration: InputDecoration(
                hintText: _isListening ? 'Speak now...' : 'Describe the problem...',
                hintStyle: const TextStyle(color: _RRColors.textMutedOnDark),
                filled: true,
                fillColor: _RRColors.glassFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _RRColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _RRColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _RRColors.aiViolet, width: 1.4),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: _isListening ? AppColors.emergencyRed : _RRColors.textMutedOnDark,
                  ),
                  onPressed: _toggleListening,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _RRColors.aiViolet.withValues(alpha: 0.4), blurRadius: 14),
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: _RRColors.aiViolet,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet offering "Camera" or "Gallery" as the image source for a
/// dashboard warning light photo, styled to match the glass theme.
class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: _RRColors.canvasMid.withValues(alpha: 0.92),
            border: const Border(top: BorderSide(color: _RRColors.glassBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _RRColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Warning Light Photo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 16),
              _sourceOption(
                context,
                icon: Icons.photo_camera_outlined,
                label: 'Take Photo',
                source: ImageSource.camera,
              ),
              const SizedBox(height: 10),
              _sourceOption(
                context,
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                source: ImageSource.gallery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(source),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _RRColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _RRColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: _RRColors.aiViolet, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// Plain glass pill for the quick-prompt suggestions — built by hand
/// instead of using ActionChip, since Flutter's default chip theming
/// overrides custom background/label colors with its own light-surface
/// tint, which made the white label text unreadable on a dark canvas.
class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickPromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _RRColors.glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _RRColors.glassBorder),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final _Diagnosis? diagnosis;
  final String? errorText;
  final String? imagePath;
  _ChatMessage({
    required this.text,
    required this.isUser,
    this.diagnosis,
    this.errorText,
    this.imagePath,
  });
}

class _Diagnosis {
  final String? warningLightIdentified;
  final String possibleCause;
  final String safetyAdvice;
  final bool canBeDriven;
  final String severity;
  final String nextStep;
  final String estimatedCost;
  const _Diagnosis({
    this.warningLightIdentified,
    required this.possibleCause,
    required this.safetyAdvice,
    required this.canBeDriven,
    required this.severity,
    required this.nextStep,
    required this.estimatedCost,
  });
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_RRColors.aiViolet, Color(0xFF8A5CF6)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: _RRColors.aiViolet.withValues(alpha: 0.25), blurRadius: 12),
          ],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}

/// User message bubble showing the warning-light photo the user
/// captured or picked, sent in place of a text bubble.
class _UserImageBubble extends StatelessWidget {
  final String imagePath;
  const _UserImageBubble({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          border: Border.all(color: _RRColors.glassBorder),
          boxShadow: [
            BoxShadow(color: _RRColors.aiViolet.withValues(alpha: 0.2), blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: Image.file(File(imagePath), fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _RRColors.glassFill,
          border: Border.all(color: _RRColors.glassBorder),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const SizedBox(
          width: 20,
          height: 12,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: _RRColors.aiViolet),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small colored pill showing how urgent the issue is. Green/amber/red
/// map to Low/Medium/High so it reads at a glance without needing to
/// read the label.
class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  Color get _color {
    switch (severity.trim().toLowerCase()) {
      case 'high':
        return AppColors.emergencyRed;
      case 'low':
        return AppColors.successGreen;
      case 'medium':
      default:
        return _RRColors.beaconAmber;
    }
  }

  IconData get _icon {
    switch (severity.trim().toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'low':
        return Icons.check_circle_outline_rounded;
      case 'medium':
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '${severity.trim()} Severity',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _DiagnosisBubble extends StatelessWidget {
  final _Diagnosis diagnosis;
  const _DiagnosisBubble({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_RRColors.glassFillHover, _RRColors.glassFill],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: _RRColors.glassBorder),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Diagnosis',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _RRColors.textMutedOnDark),
                      ),
                    ),
                    _SeverityBadge(severity: diagnosis.severity),
                  ],
                ),
                const SizedBox(height: 12),
                if (diagnosis.warningLightIdentified != null &&
                    diagnosis.warningLightIdentified!.trim().isNotEmpty) ...[
                  _sectionLabel('Warning Light Identified'),
                  const SizedBox(height: 4),
                  Text(diagnosis.warningLightIdentified!, style: _bodyStyle),
                  const SizedBox(height: 12),
                ],
                _sectionLabel('Possible Cause'),
                const SizedBox(height: 4),
                Text(diagnosis.possibleCause, style: _bodyStyle),
                const SizedBox(height: 12),
                _sectionLabel('Safety Advice'),
                const SizedBox(height: 4),
                Text(diagnosis.safetyAdvice, style: _bodyStyle),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: diagnosis.canBeDriven
                        ? AppColors.successGreen.withValues(alpha: 0.14)
                        : AppColors.emergencyRed.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: diagnosis.canBeDriven
                          ? AppColors.successGreen.withValues(alpha: 0.4)
                          : AppColors.emergencyRed.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        diagnosis.canBeDriven ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                        size: 18,
                        color: diagnosis.canBeDriven ? AppColors.successGreen : AppColors.emergencyRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diagnosis.canBeDriven
                              ? 'Can be driven: Yes — but get it checked soon'
                              : 'Can be driven: No — do not continue driving',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: diagnosis.canBeDriven ? AppColors.successGreen : AppColors.emergencyRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _sectionLabel('Recommended Next Step'),
                const SizedBox(height: 4),
                Text(diagnosis.nextStep, style: _bodyStyle),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee_rounded, size: 16, color: _RRColors.beaconAmber),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Estimated repair cost: ${diagnosis.estimatedCost}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _RRColors.beaconAmber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'AI-generated guidance only, not a professional inspection.',
                  style: TextStyle(fontSize: 10, color: _RRColors.textMutedOnDark, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _bodyStyle = TextStyle(fontSize: 12.5, color: Colors.white, height: 1.4);

  Widget _sectionLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _RRColors.aiViolet));
  }
}

/// Shown when the diagnosis call fails (network error, Gemini error, or
/// an empty/invalid response) so the user gets clear feedback instead
/// of a silently missing reply.
class _ErrorBubble extends StatelessWidget {
  final String text;
  const _ErrorBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: AppColors.emergencyRed.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.4)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.emergencyRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.emergencyRed)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dark gradient canvas + soft moonlight glows, shared across screens.
class _RRCanvas extends StatelessWidget {
  final Widget child;
  const _RRCanvas({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_RRColors.canvasTop, _RRColors.canvasMid, _RRColors.canvasBottom],
              stops: [0.0, 0.45, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -140,
          right: -110,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.aiViolet.withValues(alpha: 0.14),
                  _RRColors.aiViolet.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -130,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.mistLavender.withValues(alpha: 0.10),
                  _RRColors.mistLavender.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
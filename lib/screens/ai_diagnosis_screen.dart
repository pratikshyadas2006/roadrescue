import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

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
/// User picks a common symptom or types their own. A simulated AI response
/// gives possible causes, basic troubleshooting, and whether to call a
/// mechanic immediately. NOTE: this is a rule-based placeholder — swap
/// `_generateDiagnosis` for a real API call to your PHP backend / AI
/// service when ready.
class AiDiagnosisScreen extends StatefulWidget {
  const AiDiagnosisScreen({super.key});

  @override
  State<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}

class _AiDiagnosisScreenState extends State<AiDiagnosisScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  final List<String> _quickPrompts = const [
    "Car won't start",
    'Battery warning light is on',
    'Engine overheating',
    'Strange engine noise',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isThinking = true;
      _controller.clear();
    });

    // Simulated "AI thinking" delay before showing the diagnosis.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: '',
          isUser: false,
          diagnosis: _generateDiagnosis(text),
        ));
        _isThinking = false;
      });
    });
  }

  /// Very simple keyword-matched placeholder logic.
  /// Replace with a real AI/LLM call to your backend for the final build.
  _Diagnosis _generateDiagnosis(String input) {
    final String lower = input.toLowerCase();

    if (lower.contains("won't start") || lower.contains('not starting') || lower.contains('wont start')) {
      return const _Diagnosis(
        causes: ['Dead or weak battery', 'Faulty starter motor', 'Empty fuel tank', 'Bad ignition switch'],
        tips: ['Check if headlights/dashboard lights turn on', 'Try jump-starting the battery', 'Check fuel gauge'],
        callMechanic: true,
      );
    }
    if (lower.contains('battery')) {
      return const _Diagnosis(
        causes: ['Battery is undercharged or old', 'Loose or corroded terminals', 'Alternator not charging properly'],
        tips: ['Check terminal connections are tight and clean', 'Avoid switching off engine until you reach a garage'],
        callMechanic: true,
      );
    }
    if (lower.contains('overheat')) {
      return const _Diagnosis(
        causes: ['Low coolant level', 'Faulty radiator fan', 'Coolant leak', 'Blocked radiator'],
        tips: ['Pull over safely and switch off the engine immediately', 'Do NOT open the radiator cap while hot', 'Wait for the engine to cool before checking coolant'],
        callMechanic: true,
      );
    }
    if (lower.contains('noise') || lower.contains('sound')) {
      return const _Diagnosis(
        causes: ['Worn belt or pulley', 'Low engine oil', 'Loose exhaust component'],
        tips: ['Check engine oil level', 'Avoid high speeds until inspected', 'Note when the noise happens (idle, acceleration, braking)'],
        callMechanic: false,
      );
    }
    if (lower.contains('tyre') || lower.contains('tire') || lower.contains('flat')) {
      return const _Diagnosis(
        causes: ['Puncture from road debris', 'Under-inflation', 'Worn-out tyre tread'],
        tips: ['Use the spare tyre if you have one and know how to change it', 'Turn on hazard lights and move to a safe spot'],
        callMechanic: false,
      );
    }
    if (lower.contains('brake')) {
      return const _Diagnosis(
        causes: ['Worn brake pads', 'Low brake fluid', 'Air in brake lines'],
        tips: ['Avoid driving further if brakes feel soft or unresponsive', 'Do not ignore grinding or squealing sounds'],
        callMechanic: true,
      );
    }

    // Fallback for anything unmatched.
    return const _Diagnosis(
      causes: ['Could be several things — hard to tell without more detail'],
      tips: ['Describe when the issue happens (starting, driving, braking, idle)', 'Check for warning lights on your dashboard'],
      callMechanic: true,
    );
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
                          return msg.isUser
                              ? _UserBubble(text: msg.text)
                              : _DiagnosisBubble(diagnosis: msg.diagnosis!);
                        },
                      ),
              ),
              _buildInputBar(),
            ],
          ),
        ),
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
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _sendMessage,
              style: const TextStyle(color: Colors.white),
              cursorColor: _RRColors.aiViolet,
              decoration: InputDecoration(
                hintText: 'Describe the problem...',
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
  _ChatMessage({required this.text, required this.isUser, this.diagnosis});
}

class _Diagnosis {
  final List<String> causes;
  final List<String> tips;
  final bool callMechanic;
  const _Diagnosis({required this.causes, required this.tips, required this.callMechanic});
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
                const Text('Possible Causes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _RRColors.aiViolet)),
                const SizedBox(height: 6),
                ...diagnosis.causes.map((c) => _bullet(c)),
                const SizedBox(height: 12),
                const Text('Basic Troubleshooting', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _RRColors.aiViolet)),
                const SizedBox(height: 6),
                ...diagnosis.tips.map((t) => _bullet(t)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: diagnosis.callMechanic
                        ? AppColors.emergencyRed.withValues(alpha: 0.14)
                        : AppColors.successGreen.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: diagnosis.callMechanic
                          ? AppColors.emergencyRed.withValues(alpha: 0.4)
                          : AppColors.successGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        diagnosis.callMechanic ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                        size: 18,
                        color: diagnosis.callMechanic ? AppColors.emergencyRed : AppColors.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diagnosis.callMechanic
                              ? 'Recommended: call a mechanic now'
                              : 'You can likely continue, but get it checked soon',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: diagnosis.callMechanic ? AppColors.emergencyRed : AppColors.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This is guidance only, not a professional inspection.',
                  style: TextStyle(fontSize: 10, color: _RRColors.textMutedOnDark, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 5, color: _RRColors.textMutedOnDark),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, color: Colors.white))),
        ],
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
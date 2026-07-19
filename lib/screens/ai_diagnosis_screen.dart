import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(Icons.psychology_alt_outlined, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'AI Diagnosis',
              style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
              color: Colors.purple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_alt_outlined, color: Colors.purple, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            "Tell me what's wrong with your vehicle",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          const Text(
            'This is guidance only — not a replacement\nfor a professional inspection.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _quickPrompts.map((p) {
              return ActionChip(
                label: Text(p, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                onPressed: () => _sendMessage(p),
              );
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
              decoration: InputDecoration(
                hintText: 'Describe the problem...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.secondary, size: 18),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ),
        ],
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
          color: AppColors.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
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
          color: Colors.white,
          border: Border.all(color: AppColors.border),
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
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Possible Causes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 6),
            ...diagnosis.causes.map((c) => _bullet(c)),
            const SizedBox(height: 12),
            const Text('Basic Troubleshooting', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 6),
            ...diagnosis.tips.map((t) => _bullet(t)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: diagnosis.callMechanic
                    ? AppColors.emergencyRed.withValues(alpha: 0.1)
                    : AppColors.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
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
              style: TextStyle(fontSize: 10, color: Colors.black38, fontStyle: FontStyle.italic),
            ),
          ],
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
            child: Icon(Icons.circle, size: 5, color: Colors.black45),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, color: Colors.black87))),
        ],
      ),
    );
  }
}
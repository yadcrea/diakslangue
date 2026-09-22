import 'package:flutter/material.dart';
import '../models/language_model.dart';
import '../services/onboarding_service.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

class OnboardingLevelScreen extends StatelessWidget {
  final LanguageModel language;
  final bool isReonboarding;

  const OnboardingLevelScreen({
    super.key,
    required this.language,
    this.isReonboarding = false,
  });

  static const _levels = [
    (label: 'Je débute en', bars: 1),
    (label: 'Je connais quelques mots de base', bars: 2),
    (label: 'Je peux avoir une conversation simple', bars: 3),
    (label: 'Je peux parler de sujets variés', bars: 4),
    (label: 'Je peux parler de nombreux sujets de façon approfondie', bars: 5),
  ];

  Future<void> _goToLanguage(BuildContext context) async {
    await OnboardingService.setMainLanguage(language);
    if (!context.mounted) return;

    if (isReonboarding) {
      Navigator.pop(context, language);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainShell(initialLanguage: language),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Mascot + speech bubble
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo mascot
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: language.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Speech bubble
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(
                            color: const Color(0xFFE5E5E5), width: 1.5),
                      ),
                      child: Text(
                        'Tu as déjà des bases en ${language.name} ?',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Level choices
              Expanded(
                child: ListView.separated(
                  itemCount: _levels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    final label = index == 0
                        ? '${level.label} ${language.name}'
                        : level.label;
                    return _LevelButton(
                      label: label,
                      bars: level.bars,
                      onTap: () => _goToLanguage(context),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String label;
  final int bars;
  final VoidCallback onTap;

  const _LevelButton({
    required this.label,
    required this.bars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
        ),
        child: Row(
          children: [
            _BarIcon(bars: bars),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final int bars; // 1-5

  const _BarIcon({required this.bars});

  @override
  Widget build(BuildContext context) {
    const heights = [7.0, 12.0, 17.0];
    // bars 1 → 0 filled, 2 → 1, 3 → 2, 4-5 → all 3
    final filled = bars <= 1 ? 0 : bars <= 2 ? 1 : bars <= 3 ? 2 : 3;

    return SizedBox(
      width: 28,
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(3, (i) {
          final active = i < filled;
          return Container(
            width: 6,
            height: heights[i],
            margin: EdgeInsets.only(left: i > 0 ? 3 : 0),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF1CB0F6)
                  : const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

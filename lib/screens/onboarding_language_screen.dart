import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import '../models/languages_data.dart';
import '../models/language_model.dart';
import '../theme/app_colors.dart';
import 'onboarding_level_screen.dart';

class OnboardingLanguageScreen extends StatefulWidget {
  const OnboardingLanguageScreen({super.key});

  @override
  State<OnboardingLanguageScreen> createState() =>
      _OnboardingLanguageScreenState();
}

class _OnboardingLanguageScreenState extends State<OnboardingLanguageScreen> {
  LanguageModel? _selected;

  void _continue() {
    if (_selected == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingLevelScreen(language: _selected!),
      ),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            onPressed: _selected != null ? _continue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selected != null ? const Color(0xFF58CC02) : const Color(0xFFE5E5E5),
              foregroundColor:
                  _selected != null ? Colors.white : const Color(0xFFAAAAAA),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: _selected != null ? 4 : 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Continuer',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Text(
                'Que veux-tu\napprendre ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                  height: 1.25,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Choisis une langue pour commencer',
                style: TextStyle(fontSize: 15, color: AppColors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: allLanguages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lang = allLanguages[index];
                  final isSelected = _selected?.id == lang.id;
                  return _LanguageTile(
                    language: lang,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selected = lang),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? language.color.withValues(alpha: 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? language.color : const Color(0xFFE5E5E5),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: language.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: CountryFlag.fromCountryCode(
                  language.countryCode,
                  theme: const ImageTheme(
                    width: 44,
                    height: 32,
                    shape: RoundedRectangle(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? language.color : AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    language.country,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: language.color, size: 24)
            else
              const Icon(Icons.chevron_right,
                  color: AppColors.grey, size: 24),
          ],
        ),
      ),
    );
  }
}

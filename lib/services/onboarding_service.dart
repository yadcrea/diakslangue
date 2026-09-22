import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_model.dart';
import '../models/languages_data.dart';

class OnboardingService {
  static const _mainLanguageKey = 'main_language_id';

  static Future<LanguageModel?> getMainLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_mainLanguageKey);
      if (id == null) return null;
      for (final lang in allLanguages) {
        if (lang.id == id) return lang;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setMainLanguage(LanguageModel language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mainLanguageKey, language.id);
    } catch (_) {
      // Stockage local indisponible sur ce navigateur : on continue quand
      // même, la langue principale ne sera simplement pas mémorisée.
    }
  }
}

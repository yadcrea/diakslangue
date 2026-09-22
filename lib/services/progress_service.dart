import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _completedKey = 'completed_courses';
  static const _xpKey = 'total_xp';
  static const _starsKey = 'stars_';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  // Le stockage local (SharedPreferences) peut échouer sur certains
  // navigateurs mobiles (mode privé, cookies bloqués, etc.). Chaque méthode
  // se protège pour ne jamais bloquer l'appli : on retombe sur des valeurs
  // par défaut plutôt que de laisser une exception remonter.

  static Future<Set<String>> getCompleted() async {
    try {
      final p = await _prefs();
      return (p.getStringList(_completedKey) ?? []).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<bool> isCourseCompleted(String courseId) async {
    final completed = await getCompleted();
    return completed.contains(courseId);
  }

  static Future<int> getStars(String courseId) async {
    try {
      final p = await _prefs();
      return p.getInt('$_starsKey$courseId') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<int> getTotalXP() async {
    try {
      final p = await _prefs();
      return p.getInt(_xpKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> completeCourse(String courseId, int stars, int xpEarned) async {
    try {
      final p = await _prefs();
      final completed = (p.getStringList(_completedKey) ?? []).toSet();
      completed.add(courseId);
      await p.setStringList(_completedKey, completed.toList());

      final prevStars = p.getInt('$_starsKey$courseId') ?? 0;
      if (stars > prevStars) {
        await p.setInt('$_starsKey$courseId', stars);
      }

      final currentXP = p.getInt(_xpKey) ?? 0;
      await p.setInt(_xpKey, currentXP + xpEarned);
    } catch (_) {
      // Progression non sauvegardée cette fois, mais l'appli continue.
    }
  }

  static Future<Map<String, int>> getAllStars(List<String> courseIds) async {
    try {
      final p = await _prefs();
      return {
        for (final id in courseIds) id: p.getInt('$_starsKey$id') ?? 0,
      };
    } catch (_) {
      return {for (final id in courseIds) id: 0};
    }
  }

  static int calculateStars(int score, int total) {
    if (total == 0) return 1;
    final pct = score / total;
    if (pct >= 0.9) return 3;
    if (pct >= 0.6) return 2;
    return 1;
  }

  static int calculateXP(int score, int total, int stars) {
    return score * 10 + stars * 20;
  }

  static String getUserLevel(int xp) {
    if (xp >= 500) return 'Expert';
    if (xp >= 200) return 'Avancé';
    if (xp >= 50) return 'Intermédiaire';
    return 'Débutant';
  }

  static int xpForNextLevel(int xp) {
    if (xp >= 500) return 500;
    if (xp >= 200) return 500;
    if (xp >= 50) return 200;
    return 50;
  }

  static int xpForCurrentLevel(int xp) {
    if (xp >= 500) return 200;
    if (xp >= 200) return 50;
    if (xp >= 50) return 50;
    return 0;
  }
}

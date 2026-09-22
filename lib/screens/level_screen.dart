import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import '../theme/app_colors.dart';
import '../models/language_model.dart';
import '../models/languages_data.dart';
import '../services/progress_service.dart';
import 'lesson_screen.dart';
import 'vocabulary_screen.dart';
import 'word_list_screen.dart';
import 'salutation_flashcard_screen.dart';
import 'flashcard_screen.dart';
import 'onboarding_level_screen.dart';

class LevelScreen extends StatefulWidget {
  final LanguageModel language;
  final ValueChanged<LanguageModel>? onLanguageChanged;

  const LevelScreen({
    super.key,
    required this.language,
    this.onLanguageChanged,
  });

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  Map<String, int> _stars = {};
  Set<String> _completed = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = widget.language.courses.map((c) => c.id).toList();
    final stars = await ProgressService.getAllStars(ids);
    final completed = await ProgressService.getCompleted();
    if (mounted) {
      setState(() {
        _stars = stars;
        _completed = completed;
        _loaded = true;
      });
    }
  }

  List<CourseModel> _coursesForLevel(int level) =>
      widget.language.courses.where((c) => c.level == level).toList();

  int _completedCount(List<CourseModel> courses) =>
      courses.where((c) => _completed.contains(c.id)).length;

  bool _isLevelUnlocked(int level) {
    // TEMPORAIRE : tout débloqué pour travailler sur les niveaux.
    // Remettre la logique ci-dessous pour réactiver le verrouillage normal :
    // if (level == 1) return true;
    // final prev = _coursesForLevel(level - 1);
    // if (prev.isEmpty) return true;
    // return _completedCount(prev) >= (prev.length / 2).ceil();
    return true;
  }

  void _showLanguageSwitcher(BuildContext context, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Changer de langue',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: allLanguages.map((lang) {
                  final isCurrent = lang.id == widget.language.id;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: lang.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: CountryFlag.fromCountryCode(
                          lang.countryCode,
                          theme: const ImageTheme(
                              width: 34, height: 24, shape: RoundedRectangle(6)),
                        ),
                      ),
                    ),
                    title: Text(lang.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? lang.color : AppColors.navy)),
                    subtitle: Text(lang.country,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey)),
                    trailing: isCurrent
                        ? Icon(Icons.check_circle, color: lang.color)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      if (isCurrent) return;
                      final newLanguage = await Navigator.push<LanguageModel>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OnboardingLevelScreen(
                            language: lang,
                            isReonboarding: true,
                          ),
                        ),
                      );
                      if (newLanguage != null) {
                        widget.onLanguageChanged?.call(newLanguage);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCourse(CourseModel course) {
    final color = widget.language.color;
    final name = widget.language.name;

    Widget screen;
    if (course.id.endsWith('-c1') && widget.language.id == 'diakhango') {
      screen = SalutationFlashcardScreen(
          course: course, languageName: name, languageColor: color);
    } else if ((course.id.endsWith('-c7') || course.id.endsWith('-c8')) && widget.language.id == 'diakhango') {
      screen = WordListScreen(
          course: course, languageName: name, languageColor: color);
    } else {
      screen = LessonScreen(
          course: course, languageName: name, languageColor: color);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.language.color;
    final levels = [1, 2, 3];
    final levelNames = {
      1: 'Débutant',
      2: 'Intermédiaire',
      3: 'Avancé',
    };
    final levelIcons = {
      1: Icons.star_outline_rounded,
      2: Icons.star_half_rounded,
      3: Icons.star_rounded,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CountryFlag.fromCountryCode(
              widget.language.countryCode,
              theme: const ImageTheme(width: 32, height: 24, shape: RoundedRectangle(4)),
            ),
            const SizedBox(width: 8),
            Text(widget.language.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            tooltip: 'Changer de langue',
            onPressed: () => _showLanguageSwitcher(context, color),
          ),
        ],
      ),
      body: _loaded
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // XP header
                _XPHeader(languageColor: color, language: widget.language),
                const SizedBox(height: 16),
                // Flashcards Dioula — Diakhango uniquement
                if (widget.language.id == 'diakhango')
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FlashcardScreen())),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Color(0x337C3AED), blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.style, color: Colors.white, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Flashcards Dioula',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                // Levels
                ...levels.map((lvl) {
                  final courses = _coursesForLevel(lvl);
                  if (courses.isEmpty) return const SizedBox.shrink();
                  final unlocked = _isLevelUnlocked(lvl);
                  final done = _completedCount(courses);

                  return _LevelSection(
                    level: lvl,
                    name: levelNames[lvl]!,
                    icon: levelIcons[lvl]!,
                    courses: courses,
                    completed: done,
                    unlocked: unlocked,
                    stars: _stars,
                    color: color,
                    onCourseTap: unlocked ? _openCourse : null,
                    onVocabTap: (course) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VocabularyScreen(
                          course: course,
                          languageName: widget.language.name,
                          languageColor: color,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            )
          : Center(
              child: CircularProgressIndicator(color: color),
            ),
    );
  }
}

// ─── XP Header ───────────────────────────────────────────────────────────────

class _XPHeader extends StatefulWidget {
  final Color languageColor;
  final LanguageModel language;

  const _XPHeader({required this.languageColor, required this.language});

  @override
  State<_XPHeader> createState() => _XPHeaderState();
}

class _XPHeaderState extends State<_XPHeader> {
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    ProgressService.getTotalXP().then((xp) {
      if (mounted) setState(() => _xp = xp);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.languageColor;
    final level = ProgressService.getUserLevel(_xp);
    final nextXP = ProgressService.xpForNextLevel(_xp);
    final curXP = ProgressService.xpForCurrentLevel(_xp);
    final progress = nextXP > curXP ? (_xp - curXP) / (nextXP - curXP) : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_xp XP',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ta progression',
            style: TextStyle(
                color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_xp / $nextXP XP pour le prochain niveau',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Level Section ────────────────────────────────────────────────────────────

class _LevelSection extends StatelessWidget {
  final int level;
  final String name;
  final IconData icon;
  final List<CourseModel> courses;
  final int completed;
  final bool unlocked;
  final Map<String, int> stars;
  final Color color;
  final void Function(CourseModel)? onCourseTap;
  final void Function(CourseModel) onVocabTap;

  const _LevelSection({
    required this.level,
    required this.name,
    required this.icon,
    required this.courses,
    required this.completed,
    required this.unlocked,
    required this.stars,
    required this.color,
    required this.onCourseTap,
    required this.onVocabTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = courses.isEmpty ? 0.0 : completed / courses.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Level header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: unlocked
                  ? color.withValues(alpha: 0.08)
                  : const Color(0xFFF0F0F0),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: unlocked ? color : AppColors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    unlocked ? icon : Icons.lock_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Niveau $level — $name',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: unlocked ? AppColors.navy : AppColors.grey,
                            ),
                          ),
                          if (!unlocked) ...[
                            const SizedBox(width: 6),
                            const Text('🔒',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              unlocked ? color.withValues(alpha: 0.15) : const Color(0xFFE0E0E0),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(unlocked ? color : AppColors.grey),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$completed / ${courses.length} cours terminés',
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                unlocked ? color : AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Course list
          ...courses.asMap().entries.map((e) {
            final course = e.value;
            final courseStars = stars[course.id] ?? 0;
            final isDone = courseStars > 0;

            return _CourseRow(
              course: course,
              stars: courseStars,
              isDone: isDone,
              unlocked: unlocked,
              color: color,
              isLast: e.key == courses.length - 1,
              onTap: onCourseTap != null ? () => onCourseTap!(course) : null,
              onVocabTap: () => onVocabTap(course),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Course Row ───────────────────────────────────────────────────────────────

class _CourseRow extends StatelessWidget {
  final CourseModel course;
  final int stars;
  final bool isDone;
  final bool unlocked;
  final Color color;
  final bool isLast;
  final VoidCallback? onTap;
  final VoidCallback onVocabTap;

  const _CourseRow({
    required this.course,
    required this.stars,
    required this.isDone,
    required this.unlocked,
    required this.color,
    required this.isLast,
    required this.onTap,
    required this.onVocabTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: unlocked ? onTap : null,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(20))
          : BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFF0EDE8)),
          ),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? color.withValues(alpha: 0.1)
                    : unlocked
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : unlocked
                        ? Icons.play_circle_outline_rounded
                        : Icons.lock_rounded,
                color: isDone ? color : AppColors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Title + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? AppColors.navy : AppColors.grey,
                    ),
                  ),
                  Text(
                    '${course.lessons.length} leçon${course.lessons.length > 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 12,
                        color: unlocked ? color : AppColors.grey),
                  ),
                ],
              ),
            ),

            // Stars
            if (isDone)
              Row(
                children: List.generate(3, (i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < stars ? Colors.amber : const Color(0xFFDDD8D0),
                  size: 16,
                )),
              ),

            // Vocab button
            if (unlocked)
              IconButton(
                icon: const Icon(Icons.list_alt_rounded,
                    color: AppColors.grey, size: 20),
                onPressed: onVocabTap,
                tooltip: 'Vocabulaire',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),

            // Play button
            if (unlocked)
              Icon(Icons.chevron_right_rounded,
                  color: isDone ? color : AppColors.grey),
          ],
        ),
      ),
    );
  }
}

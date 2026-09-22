import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/language_model.dart';
import '../services/audio_service.dart';
import 'lesson_screen.dart';

class _FlashCard {
  final String diakhango;
  final String french;
  final String? audioPath;
  final String? imagePath;
  final String category;

  const _FlashCard({
    required this.diakhango,
    required this.french,
    this.audioPath,
    this.imagePath,
    required this.category,
  });
}

class SalutationFlashcardScreen extends StatefulWidget {
  final CourseModel course;
  final String languageName;
  final Color languageColor;

  const SalutationFlashcardScreen({
    super.key,
    required this.course,
    required this.languageName,
    required this.languageColor,
  });

  @override
  State<SalutationFlashcardScreen> createState() =>
      _SalutationFlashcardScreenState();
}

class _SalutationFlashcardScreenState extends State<SalutationFlashcardScreen>
    with SingleTickerProviderStateMixin {
  final _audio = AudioService();
  final _pageCtrl = PageController();
  int _current = 0;
  bool _isPlaying = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  List<_FlashCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _buildCards();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _buildCards() {
    final lessonLabels = <String>[];
    for (final lesson in widget.course.lessons) {
      for (final _ in lesson.exercises) {
        lessonLabels.add(lesson.title);
      }
    }

    final allExercises =
        widget.course.lessons.expand((l) => l.exercises).toList();

    final seen = <String>{};
    final cards = <_FlashCard>[];
    int i = 0;
    for (final ex in allExercises) {
      final word = ex.subtitle;
      if (word == null || seen.contains(word)) {
        i++;
        continue;
      }
      seen.add(word);
      cards.add(_FlashCard(
        diakhango: word,
        french: ex.translation ?? ex.correctAnswer,
        audioPath: ex.audioFileName,
        imagePath: ex.imagePath,
        category: i < lessonLabels.length ? lessonLabels[i] : '',
      ));
      i++;
    }
    _cards = cards;
  }

  Future<void> _playAudio(String? path) async {
    if (path == null || _isPlaying) return;
    setState(() => _isPlaying = true);
    await _audio.playAsset(path);
    if (mounted) setState(() => _isPlaying = false);
  }

  void _goTo(int index) {
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.languageColor;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(widget.languageName,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonScreen(
                  course: widget.course,
                  languageName: widget.languageName,
                  languageColor: color,
                ),
              ),
            ),
            icon: const Icon(Icons.quiz_rounded, color: Colors.white, size: 20),
            label: const Text('Quiz',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            color: color,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Text(
                  '${_current + 1} / ${_cards.length}',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _cards.isEmpty
                          ? 0
                          : (_current + 1) / _cards.length,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: _cards.length,
              onPageChanged: (i) => setState(() {
                _current = i;
                _isPlaying = false;
              }),
              itemBuilder: (context, i) => _buildCard(_cards[i], color, i),
            ),
          ),

          // Dot indicator
          _buildDots(color),
        ],
      ),
    );
  }

  Widget _buildCard(_FlashCard card, Color color, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    // Photo area
                    Expanded(
                      flex: 6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (card.imagePath != null)
                            Image.asset(
                              card.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color:
                                    color.withValues(alpha: 0.08),
                                child: Icon(Icons.record_voice_over,
                                    size: 80,
                                    color: color.withValues(alpha: 0.4)),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    color.withValues(alpha: 0.15),
                                    color.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Icon(Icons.record_voice_over,
                                  size: 80,
                                  color: color.withValues(alpha: 0.4)),
                            ),
                          // Gradient overlay bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 80,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.95),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Category badge
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                card.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Text area
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Diakhango word
                            Text(
                              card.diakhango,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: color,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Divider
                            Container(
                              width: 40,
                              height: 2,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // French translation
                            Text(
                              card.french,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                color: AppColors.navy,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Audio button
                            GestureDetector(
                              onTap: () => _playAudio(card.audioPath),
                              child: AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (context, child) {
                                  final isCurrentPlaying =
                                      _isPlaying && _current == index;
                                  return Transform.scale(
                                    scale: isCurrentPlaying
                                        ? _pulseAnim.value
                                        : 1.0,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: card.audioPath != null
                                        ? color
                                        : const Color(0xFFDDD8D0),
                                    shape: BoxShape.circle,
                                    boxShadow: card.audioPath != null
                                        ? [
                                            BoxShadow(
                                              color:
                                                  color.withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Icon(
                                    _isPlaying && _current == index
                                        ? Icons.graphic_eq
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation arrows
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: _current > 0 ? () => _goTo(_current - 1) : null,
                  color: color,
                ),
                Text(
                  'Glissez pour naviguer',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey.withValues(alpha: 0.7),
                  ),
                ),
                _NavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap:
                      _current < _cards.length - 1 ? () => _goTo(_current + 1) : null,
                  color: color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(Color color) {
    if (_cards.length <= 1) return const SizedBox(height: 16);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: 10,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: _cards.length,
          itemBuilder: (_, i) {
            final isActive = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? color : color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.12) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? color : color.withValues(alpha: 0.2),
          size: 20,
        ),
      ),
    );
  }
}

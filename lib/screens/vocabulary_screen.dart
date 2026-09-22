import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/language_model.dart';
import '../services/audio_service.dart';

class VocabularyScreen extends StatefulWidget {
  final CourseModel course;
  final String languageName;
  final Color languageColor;

  const VocabularyScreen({
    super.key,
    required this.course,
    required this.languageName,
    required this.languageColor,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  final _audio = AudioService();
  int _currentIndex = 0;
  bool _revealed = false;
  bool _isPlaying = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  late List<ExerciseModel> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = widget.course.lessons.expand((l) => l.exercises).toList();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _extractFrench(String question) {
    final match = RegExp(r'"([^"]+)"').firstMatch(question);
    return match?.group(1) ?? question;
  }

  Future<void> _play(String? audioFile) async {
    if (audioFile == null) return;
    setState(() => _isPlaying = true);
    await _audio.playAsset(audioFile);
    if (mounted) setState(() => _isPlaying = false);
  }

  void _reveal() {
    setState(() => _revealed = true);
    _animController.forward(from: 0);
  }

  void _goTo(int index) {
    setState(() {
      _currentIndex = index;
      _revealed = false;
      _isPlaying = false;
    });
    _animController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exercises[_currentIndex];
    final french = _extractFrench(ex.question);
    final total = _exercises.length;
    final color = widget.languageColor;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Vocabulaire · ${widget.languageName}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentIndex + 1} / $total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
              backgroundColor: color.withValues(alpha: 0.15),
              color: color,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),

            // Flashcard
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 16,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image ou icône
                      if (ex.imagePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            ex.imagePath!,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: (ex.iconColor ?? color).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: ex.icon != null
                              ? Icon(ex.icon,
                                  size: 64, color: ex.iconColor ?? color)
                              : Icon(Icons.record_voice_over,
                                  size: 64, color: color),
                        ),
                      const SizedBox(height: 28),

                      // Word in dialect
                      Text(
                        ex.correctAnswer,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Audio button
                      if (ex.audioFileName != null)
                        GestureDetector(
                          onTap: () => _play(ex.audioFileName),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPlaying
                                      ? Icons.volume_up
                                      : Icons.play_circle,
                                  color: color,
                                  size: 24,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPlaying ? 'Lecture…' : 'Écouter',
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Translation always visible
                      const SizedBox(height: 20),
                      Divider(color: color.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text(
                        french,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (ex.translationEn != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          ex.translationEn!,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Navigation
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentIndex > 0
                        ? () => _goTo(_currentIndex - 1)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentIndex < total - 1
                        ? () => _goTo(_currentIndex + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                        _currentIndex < total - 1 ? 'Suivant' : 'Terminé'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/language_model.dart';
import '../services/audio_service.dart';
import 'lesson_screen.dart';
import 'lecture_screen.dart';

class WordListScreen extends StatefulWidget {
  final CourseModel course;
  final String languageName;
  final Color languageColor;

  const WordListScreen({
    super.key,
    required this.course,
    required this.languageName,
    required this.languageColor,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final _audio = AudioService();
  String? _playingAudio;

  List<_WordEntry> _buildWords() {
    final allExercises = widget.course.lessons.expand((l) => l.exercises).toList();

    // Regroupe par subtitle pour trouver image/audio dans n'importe quel exercice du même mot
    final wordMap = <String, _WordEntry>{};
    for (final ex in allExercises) {
      final word = ex.subtitle;
      if (word == null) continue;
      final existing = wordMap[word];
      wordMap[word] = _WordEntry(
        word: word,
        translation: ex.translation ?? existing?.translation ?? '',
        translationEn: ex.translationEn ?? existing?.translationEn,
        audioPath: ex.audioFileName ?? existing?.audioPath,
        imagePath: ex.imagePath ?? existing?.imagePath,
      );
    }
    return wordMap.values.toList();
  }

  Future<void> _play(String? path) async {
    if (path == null) return;
    setState(() => _playingAudio = path);
    await _audio.playAsset(path);
    if (mounted) setState(() => _playingAudio = null);
  }

  @override
  Widget build(BuildContext context) {
    final words = _buildWords();
    final color = widget.languageColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
            icon: const Icon(Icons.play_circle_filled, color: Colors.white, size: 20),
            label: const Text('Exercices', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _buildBody(words, color),
    );
  }

  static const _domuSaboLines = [
    LectureLine(
      'Sa khu ma ko djibo sèkè ni wu li ta si nô khô tô sakhô mā',
      'Le petit-déjeuner se fait quand tu te réveilles le matin',
    ),
    LectureLine(
      'Isā fô nbè nko dji bo la / nba tan nko dii bo',
      'Je suis en train de faire mon petit-déjeuner / J\'ai fait mon petit-déjeuner',
    ),
    LectureLine(
      'da tôkha sè domu tilo tôlè ning mô khô lu bi fô gñô lā',
      'Le déjeuner se fait à midi quand les gens prennent leur pause',
    ),
    LectureLine(
      'Isā fô nbè nda tôkha la / nba tan nda tôkha',
      'Je suis en train de déjeuner / J\'ai déjeuné',
    ),
    LectureLine(
      'si ma gñô sè domu wura lalè',
      'Le dîner se fait le soir',
    ),
  ];

  Widget _buildBody(List<_WordEntry> words, Color color) {
    final isRepas = widget.course.id.endsWith('-c8');
    final totalItems = (isRepas ? 1 : 0) + words.length;

    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: totalItems,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          // Carte Domu sabo en premier pour les repas
          if (isRepas && i == 0) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LectureScreen(
                    title: 'Domu sabo',
                    frenchTitle: 'Trois repas',
                    languageColor: color,
                    audioFileName: 'audio/diakhango/domu_sabo.mp3',
                    lines: _domuSaboLines,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.75)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Domu sabo',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Trois repas — écouter le texte',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_circle_filled, color: Colors.white, size: 32),
                  ],
                ),
              ),
            );
          }

          final w = words[isRepas ? i - 1 : i];
          final isPlaying = _playingAudio == w.audioPath;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Speaker icon
                  GestureDetector(
                    onTap: () => _play(w.audioPath),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                        color: color,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Word + translation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.word,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          w.translation,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                        if (w.translationEn != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            w.translationEn!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Image à droite (tappable pour jouer l'audio)
                  if (w.imagePath != null)
                    GestureDetector(
                      onTap: () => _play(w.audioPath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          w.imagePath!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDDD8D0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.course.title,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.navy,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
  }
}

class _WordEntry {
  final String word;
  final String translation;
  final String? translationEn;
  final String? audioPath;
  final String? imagePath;

  _WordEntry({
    required this.word,
    required this.translation,
    this.translationEn,
    this.audioPath,
    this.imagePath,
  });
}

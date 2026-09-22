import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/language_model.dart';
import '../services/audio_service.dart';
import 'lesson_result_screen.dart';
import 'matching_game_screen.dart';

class LessonScreen extends StatefulWidget {
  final CourseModel course;
  final String languageName;
  final Color languageColor;

  const LessonScreen({
    super.key,
    required this.course,
    required this.languageName,
    required this.languageColor,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _lessonIndex = 0;
  int _exerciseIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _isPlaying = false;
  List<String> _shuffledChoices = [];

  final _audio = AudioService();

  LessonModel get _currentLesson => widget.course.lessons[_lessonIndex];
  ExerciseModel get _currentExercise => _currentLesson.exercises[_exerciseIndex];

  int get _totalExercisesInCourse =>
      widget.course.lessons.fold(0, (sum, l) => sum + l.exercises.length);

  int get _completedExercises {
    int done = 0;
    for (int i = 0; i < _lessonIndex; i++) {
      done += widget.course.lessons[i].exercises.length;
    }
    done += _exerciseIndex;
    return done;
  }

  @override
  void initState() {
    super.initState();
    _shuffleChoices();
    _playCurrentAudio();
  }

  void _shuffleChoices() {
    _shuffledChoices = List.from(_currentExercise.choices)..shuffle(Random());
  }

  Future<void> _playCurrentAudio() async {
    final audio = _currentExercise.audioFileName;
    if (audio == null) return;
    setState(() => _isPlaying = true);
    await _audio.playAsset(audio);
    if (mounted) setState(() => _isPlaying = false);
  }

  // For text exercises: select + immediately show feedback
  void _selectAnswer(String answer) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == _currentExercise.correctAnswer) _score++;
    });
  }

  // For imageChoice: only highlight selection, wait for VALIDER
  void _selectImageOnly(String label) {
    if (_answered) return;
    setState(() => _selectedAnswer = label);
  }

  void _validate() {
    if (_selectedAnswer == null || _answered) return;
    setState(() {
      _answered = true;
      if (_selectedAnswer == _currentExercise.correctAnswer) _score++;
    });
  }

  void _next() {
    final exercises = _currentLesson.exercises;
    if (_exerciseIndex < exercises.length - 1) {
      setState(() {
        _exerciseIndex++;
        _selectedAnswer = null;
        _answered = false;
        _shuffleChoices();
      });
      _playCurrentAudio();
      return;
    }

    // Fin de la leçon : petit jeu bonus "relie les mots" avant de continuer.
    final finishedLessonExercises = _currentLesson.exercises;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchingGameScreen(
          exercises: finishedLessonExercises,
          languageColor: widget.languageColor,
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      if (_lessonIndex < widget.course.lessons.length - 1) {
        setState(() {
          _lessonIndex++;
          _exerciseIndex = 0;
          _selectedAnswer = null;
          _answered = false;
          _shuffleChoices();
        });
        _playCurrentAudio();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LessonResultScreen(
              score: _score,
              total: _totalExercisesInCourse,
              languageName: widget.languageName,
              courseTitle: widget.course.title,
              courseId: widget.course.id,
              color: widget.languageColor,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalExercisesInCourse;
    final done = _completedExercises;
    final progress = total > 0 ? done / total : 0.0;
    final isImageChoice = _currentExercise.type == ExerciseType.imageChoice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.lightGrey,
          color: widget.languageColor,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.red, size: 20),
                const SizedBox(width: 4),
                const Text('5',
                    style: TextStyle(
                        color: AppColors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isImageChoice
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _answered
                    ? _FeedbackBar(
                        isCorrect:
                            _selectedAnswer == _currentExercise.correctAnswer,
                        correctAnswer: _currentExercise.correctAnswer,
                        onNext: _next,
                        color: widget.languageColor,
                        onReplay: _playCurrentAudio,
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _selectedAnswer != null ? _validate : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedAnswer != null
                                ? const Color(0xFF58CC02)
                                : const Color(0xFFE5E5E5),
                            foregroundColor: _selectedAnswer != null
                                ? Colors.white
                                : const Color(0xFFAAAAAA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: _selectedAnswer != null ? 4 : 0,
                            shadowColor: _selectedAnswer != null
                                ? const Color(0xFF3EA700)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('VALIDER',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ),
                      ),
              ),
            )
          : _answered
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _FeedbackBar(
                      isCorrect:
                          _selectedAnswer == _currentExercise.correctAnswer,
                      correctAnswer: _currentExercise.correctAnswer,
                      onNext: _next,
                      color: widget.languageColor,
                      onReplay: _currentExercise.audioFileName != null
                          ? _playCurrentAudio
                          : null,
                    ),
                  ),
                )
              : null,
      body: isImageChoice
          ? _buildImageChoiceBody()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    _currentLesson.title,
                    style: TextStyle(
                        fontSize: 14,
                        color: widget.languageColor,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentExercise.question,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy),
                  ),
                  if (_currentExercise.imagePath != null ||
                      _currentExercise.icon != null) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentExercise.subtitle != null) ...[
                            Text(
                              _currentExercise.subtitle!,
                              style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: widget.languageColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (_currentExercise.imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                _currentExercise.imagePath!,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (_currentExercise.icon != null)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: (_currentExercise.iconColor ??
                                        widget.languageColor)
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _currentExercise.icon,
                                size: 60,
                                color: _currentExercise.iconColor ??
                                    widget.languageColor,
                              ),
                            ),
                          if (_currentExercise.translation != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _currentExercise.translation!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.navy,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (_currentExercise.translationEn != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _currentExercise.translationEn!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.navy.withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else if (_currentExercise.subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _currentExercise.subtitle!,
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: widget.languageColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_currentExercise.translationEn != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _currentExercise.translationEn!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.navy.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                  if (_currentExercise.audioFileName != null) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: _playCurrentAudio,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                widget.languageColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: widget.languageColor
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPlaying
                                    ? Icons.volume_up
                                    : Icons.play_circle,
                                color: widget.languageColor,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPlaying ? 'Lecture…' : 'Écouter',
                                style: TextStyle(
                                    color: widget.languageColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ..._shuffledChoices.map((choice) => _ChoiceButton(
                        text: choice,
                        isSelected: _selectedAnswer == choice,
                        isCorrect: _answered &&
                            choice == _currentExercise.correctAnswer,
                        isWrong: _answered &&
                            _selectedAnswer == choice &&
                            choice != _currentExercise.correctAnswer,
                        onTap: () => _selectAnswer(choice),
                      )),
                ],
              ),
            ),
    );
  }

  Widget _buildImageChoiceBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOUVEAU MOT badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome,
                        color: Color(0xFF9B59B6), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'NOUVEAU MOT',
                      style: TextStyle(
                          color: Color(0xFF9B59B6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Choisis la bonne image',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy),
              ),
              const SizedBox(height: 16),
              // Speaker button + word
              Row(
                children: [
                  GestureDetector(
                    onTap: _playCurrentAudio,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1CB0F6),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF1899D6),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.volume_up : Icons.volume_up,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentExercise.correctAnswer,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy),
                      ),
                      const Text(
                        '• • •',
                        style: TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 12,
                            letterSpacing: 3),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ImageChoiceGrid(
              imageChoices: _currentExercise.imageChoices!,
              selected: _selectedAnswer,
              answered: _answered,
              correctAnswer: _currentExercise.correctAnswer,
              onSelect: _selectImageOnly,
              onPlayAudio: (audioPath) => _audio.playAsset(audioPath),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageChoiceGrid extends StatelessWidget {
  final List<ImageChoice> imageChoices;
  final String? selected;
  final bool answered;
  final String correctAnswer;
  final void Function(String) onSelect;
  final void Function(String audioPath) onPlayAudio;

  const _ImageChoiceGrid({
    required this.imageChoices,
    required this.selected,
    required this.answered,
    required this.correctAnswer,
    required this.onSelect,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: imageChoices.map((choice) {
        final isSelected = selected == choice.label;
        final isCorrect = answered && choice.label == correctAnswer;
        final isWrong =
            answered && isSelected && choice.label != correctAnswer;

        Color borderColor = const Color(0xFFE5E5E5);
        Color bgColor = Colors.white;
        Color labelColor = AppColors.navy;

        if (isCorrect) {
          borderColor = const Color(0xFF58CC02);
          bgColor = const Color(0xFFEEFAE0);
          labelColor = const Color(0xFF3EA700);
        } else if (isWrong) {
          borderColor = AppColors.red;
          bgColor = Colors.red.shade50;
          labelColor = AppColors.red;
        } else if (isSelected) {
          borderColor = const Color(0xFF1CB0F6);
          bgColor = const Color(0xFFE8F6FE);
          labelColor = const Color(0xFF1CB0F6);
        }

        return GestureDetector(
          onTap: answered
              ? null
              : () {
                  if (choice.audioPath != null) onPlayAudio(choice.audioPath!);
                  onSelect(choice.label);
                },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: borderColor,
                  width: isSelected || isCorrect || isWrong ? 2.5 : 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: choice.imagePath != null
                        ? Image.asset(
                            choice.imagePath!,
                            fit: BoxFit.contain,
                          )
                        : Icon(choice.icon,
                            size: 72, color: choice.color),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        choice.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: labelColor,
                        ),
                      ),
                      if (isCorrect)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.check_circle,
                              color: Color(0xFF58CC02), size: 16),
                        ),
                      if (isWrong)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.cancel,
                              color: AppColors.red, size: 16),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFDDDDDD);
    Color bgColor = Colors.white;
    Color textColor = AppColors.navy;

    if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
    } else if (isWrong) {
      borderColor = AppColors.red;
      bgColor = Colors.red.shade50;
      textColor = AppColors.red;
    } else if (isSelected) {
      borderColor = AppColors.navy;
      bgColor = AppColors.navy.withValues(alpha: 0.05);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
            if (isWrong) const Icon(Icons.cancel, color: AppColors.red),
          ],
        ),
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final VoidCallback onNext;
  final Color color;
  final VoidCallback? onReplay;

  const _FeedbackBar({
    required this.isCorrect,
    required this.correctAnswer,
    required this.onNext,
    required this.color,
    this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : AppColors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Bravo !' : 'Pas tout à fait…',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCorrect ? Colors.green.shade800 : AppColors.red,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              'La bonne réponse : $correctAnswer',
              style: const TextStyle(color: AppColors.red, fontSize: 14),
            ),
          ],
          const SizedBox(height: 12),
          if (isCorrect && onReplay != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Réécouter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? Colors.green : AppColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continuer',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

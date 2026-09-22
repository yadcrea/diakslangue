import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/language_model.dart';

/// Petit jeu bonus (non noté) affiché après chaque leçon : relier les mots
/// de la leçon à leur traduction française. Fonctionne pour toutes les
/// langues sans contenu supplémentaire, en réutilisant les mots déjà
/// présents dans les exercices de la leçon.
class MatchingGameScreen extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final Color languageColor;

  const MatchingGameScreen({
    super.key,
    required this.exercises,
    required this.languageColor,
  });

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _Pair {
  final String word;
  final String translation;
  bool matched = false;
  _Pair(this.word, this.translation);
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late final List<_Pair> _pairs;
  late final List<String> _leftItems;
  late final List<String> _rightItems;
  String? _selectedLeft;
  String? _selectedRight;
  String? _wrongLeft;
  String? _wrongRight;

  bool get _allMatched => _pairs.isNotEmpty && _pairs.every((p) => p.matched);

  @override
  void initState() {
    super.initState();
    final seen = <String>{};
    _pairs = [];
    for (final ex in widget.exercises) {
      final word = ex.subtitle ?? ex.correctAnswer;
      final translation = ex.translation;
      if (translation == null || translation.isEmpty) continue;
      if (seen.contains(word)) continue;
      seen.add(word);
      _pairs.add(_Pair(word, translation));
    }
    _leftItems = _pairs.map((p) => p.word).toList()..shuffle();
    _rightItems = _pairs.map((p) => p.translation).toList()..shuffle();
  }

  _Pair _pairForWord(String word) => _pairs.firstWhere((p) => p.word == word);
  _Pair _pairForTranslation(String t) =>
      _pairs.firstWhere((p) => p.translation == t);

  void _tapLeft(String word) {
    if (_pairForWord(word).matched) return;
    setState(() {
      _selectedLeft = word;
    });
    _tryMatch();
  }

  void _tapRight(String translation) {
    if (_pairForTranslation(translation).matched) return;
    setState(() {
      _selectedRight = translation;
    });
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedLeft == null || _selectedRight == null) return;
    final pair = _pairForWord(_selectedLeft!);
    if (pair.translation == _selectedRight) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
      setState(() {
        pair.matched = true;
        _selectedLeft = null;
        _selectedRight = null;
      });
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _wrongLeft = _selectedLeft;
        _wrongRight = _selectedRight;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _selectedLeft = null;
          _selectedRight = null;
          _wrongLeft = null;
          _wrongRight = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.languageColor;

    if (_pairs.length < 2) {
      // Pas assez de mots pour un jeu : on ne bloque pas l'utilisateur.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Relie les mots !',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Passer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _allMatched ? _buildCelebration(color) : _buildGame(color),
    );
  }

  Widget _buildGame(Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: _leftItems
                  .map((w) => _buildTile(w, isLeft: true, color: color))
                  .toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: _rightItems
                  .map((t) => _buildTile(t, isLeft: false, color: color))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String text, {required bool isLeft, required Color color}) {
    final pair = isLeft ? _pairForWord(text) : _pairForTranslation(text);
    final isSelected = isLeft ? _selectedLeft == text : _selectedRight == text;
    final isWrong = isLeft ? _wrongLeft == text : _wrongRight == text;

    Color bg = Colors.white;
    Color border = const Color(0xFFDDDDDD);
    if (pair.matched) {
      bg = const Color(0xFFD7F5D0);
      border = const Color(0xFF58CC02);
    } else if (isWrong) {
      bg = const Color(0xFFFFD9D9);
      border = const Color(0xFFFF4B4B);
    } else if (isSelected) {
      bg = color.withValues(alpha: 0.12);
      border = color;
    }

    return GestureDetector(
      onTap: pair.matched
          ? null
          : () => isLeft ? _tapLeft(text) : _tapRight(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }

  Widget _buildCelebration(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/mascotte.png', width: 140, height: 140),
          const SizedBox(height: 20),
          const Text(
            'Bravo, tu as tout relié !',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Continuer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

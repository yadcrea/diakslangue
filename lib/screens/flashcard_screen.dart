import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../models/flashcard_model.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  final _pageController = PageController();
  bool _isPlaying = false;
  int _currentIndex = 0;
  final Set<int> _favorites = {};
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
      if (state == PlayerState.playing) {
        _waveController.repeat(reverse: true);
      } else {
        _waveController.stop();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _pageController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String? audioPath) async {
    if (audioPath == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(AssetSource(audioPath));
    }
  }

  void _goToNext() {
    if (_currentIndex < dioulaSalutations.length - 1) {
      _player.stop();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrev() {
    if (_currentIndex > 0) {
      _player.stop();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F5FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Salutations Dioula',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Indicateur de progression
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_currentIndex + 1} / ${dioulaSalutations.length}',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / dioulaSalutations.length,
                      backgroundColor: const Color(0xFFD6E9F8),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF5A95D8)),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PageView des flashcards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: dioulaSalutations.length,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                _player.stop();
              },
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: SingleChildScrollView(
                  child: _buildCard(dioulaSalutations[i], i),
                ),
              ),
            ),
          ),

          // Boutons navigation + évaluation
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Row(
              children: [
                // Précédent
                _navBtn(
                  icon: Icons.arrow_back_ios,
                  onTap: _goToPrev,
                  enabled: _currentIndex > 0,
                ),
                const SizedBox(width: 10),
                // À revoir
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _goToNext,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('À revoir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFFF1F2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Je sais
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _goToNext,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Je sais !'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Suivant
                _navBtn(
                  icon: Icons.arrow_forward_ios,
                  onTap: _goToNext,
                  enabled: _currentIndex < dioulaSalutations.length - 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBtn({required IconData icon, required VoidCallback onTap, required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF84B6EB) : const Color(0xFFD6E9F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: enabled ? Colors.white : AppColors.grey),
      ),
    );
  }

  Widget _buildCard(FlashcardModel card, int index) {
    final isFav = _favorites.contains(index);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF84B6EB), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF84B6EB).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge + cœur
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A95D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text('NOUVEAU',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() =>
                      isFav ? _favorites.remove(index) : _favorites.add(index)),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFFFDA4C0),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // Image personnage
          Container(
            margin: const EdgeInsets.all(12),
            height: 170,
            decoration: BoxDecoration(
              color: const Color(0xFF84B6EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.asset(
              card.imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, error, __) => Center(
                child: Text(
                  '⚠️ $error',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Barre audio
          Container(
            color: const Color(0xFFD6E9F8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                GestureDetector(
                  onTap: card.audioPath != null ? () => _toggleAudio(card.audioPath) : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: card.audioPath != null
                          ? const Color(0xFF5A95D8)
                          : const Color(0xFFB0C8E0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying && _currentIndex == index
                          ? Icons.pause
                          : Icons.volume_up,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.audioPath != null
                            ? 'Écouter la prononciation'
                            : 'Audio bientôt disponible',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF1B4A7A)),
                      ),
                      const SizedBox(height: 5),
                      _buildWaveform(index),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Phrase dioula + traduction
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E9F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Dioula',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1B4A7A),
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                Text(
                  card.dioulaText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                    height: 1.3,
                  ),
                ),
                const Divider(color: Color(0xFFBFDAF0), thickness: 1.5, height: 18),
                Text(
                  card.frenchText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF5A95D8),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Phrase exemple
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFF16A34A), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.exampleDioula,
                        style: const TextStyle(
                            color: Color(0xFF1E1B4B),
                            fontSize: 13,
                            height: 1.4),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        card.exampleFrench,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(int cardIndex) {
    final heights = [7, 13, 20, 10, 18, 24, 15, 9, 21, 7, 17, 13, 19, 5, 16, 23, 11, 18, 8, 20];
    final active = _isPlaying && _currentIndex == cardIndex;
    return AnimatedBuilder(
      animation: _waveController,
      builder: (_, __) {
        return Row(
          children: heights.map((h) {
            final animated = active
                ? (h * (0.5 + 0.5 * _waveController.value)).toDouble()
                : h.toDouble();
            return Container(
              width: 3,
              height: animated,
              margin: const EdgeInsets.only(right: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF5A95D8),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

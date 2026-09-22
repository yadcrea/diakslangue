import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/audio_service.dart';

class LectureLine {
  final String diakhango;
  final String french;
  const LectureLine(this.diakhango, this.french);
}

class LectureScreen extends StatefulWidget {
  final String title;
  final String frenchTitle;
  final Color languageColor;
  final String audioFileName;
  final List<LectureLine> lines;
  final int msPerLine;

  const LectureScreen({
    super.key,
    required this.title,
    required this.frenchTitle,
    required this.languageColor,
    required this.audioFileName,
    required this.lines,
    this.msPerLine = 4500,
  });

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  bool _isPlaying = false;
  bool _started = false;
  int _activeLine = -1;
  Timer? _timer;
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _fades = [];
  final List<Animation<double>> _slides = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.lines.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _controllers.add(ctrl);
      _fades.add(CurvedAnimation(parent: ctrl, curve: Curves.easeIn));
      _slides.add(Tween<double>(begin: 20, end: 0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
      ));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _play() async {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
      _started = true;
      _activeLine = -1;
    });

    // Reset animations
    for (final c in _controllers) {
      c.reset();
    }

    // Play audio
    _audio.playAsset(widget.audioFileName);

    // Reveal lines one by one
    for (int i = 0; i < widget.lines.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 300 : widget.msPerLine));
      if (!mounted) return;
      setState(() => _activeLine = i);
      _controllers[i].forward();
    }

    await Future.delayed(Duration(milliseconds: widget.msPerLine));
    if (mounted) setState(() => _isPlaying = false);
  }

  void _replay() {
    setState(() {
      _isPlaying = false;
      _started = false;
      _activeLine = -1;
    });
    for (final c in _controllers) {
      c.reset();
    }
    Future.delayed(const Duration(milliseconds: 100), _play);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.languageColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(widget.frenchTitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Bouton lecture
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: _isPlaying ? null : (_started ? _replay : _play),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPlaying
                          ? Icons.graphic_eq
                          : (_started ? Icons.replay : Icons.play_circle_filled),
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isPlaying
                          ? 'Lecture en cours…'
                          : (_started ? 'Réécouter' : 'Écouter le texte'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lignes de texte
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              itemCount: widget.lines.length,
              itemBuilder: (context, i) {
                final line = widget.lines[i];
                final isActive = i == _activeLine;
                final isPast = i < _activeLine;
                final isVisible = i <= _activeLine;

                return AnimatedBuilder(
                  animation: _controllers[i],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slides[i].value),
                      child: FadeTransition(
                        opacity: _fades[i],
                        child: child,
                      ),
                    );
                  },
                  child: Visibility(
                    visible: isVisible || !_started,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: AnimatedOpacity(
                      opacity: !_started ? 0.15 : (isVisible ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive
                                ? color.withValues(alpha: 0.5)
                                : const Color(0xFFE8E0D8),
                            width: isActive ? 1.5 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(right: 10, top: 2),
                                  decoration: BoxDecoration(
                                    color: isActive || isPast
                                        ? color
                                        : color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isActive || isPast
                                            ? Colors.white
                                            : color,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    line.diakhango,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isActive
                                          ? color
                                          : AppColors.navy,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 34),
                              child: Text(
                                line.french,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                  height: 1.4,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

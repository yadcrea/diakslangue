import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/progress_service.dart';

class LessonResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String languageName;
  final String courseTitle;
  final String courseId;
  final Color color;

  const LessonResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.languageName,
    required this.courseTitle,
    required this.courseId,
    required this.color,
  });

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _starsCtrl;
  late final AnimationController _xpCtrl;
  late final Animation<double> _scaleAnim;
  int _stars = 0;
  int _xpEarned = 0;
  int _displayXP = 0;
  Timer? _xpTimer;

  @override
  void initState() {
    super.initState();

    _stars = ProgressService.calculateStars(widget.score, widget.total);
    _xpEarned = ProgressService.calculateXP(widget.score, widget.total, _stars);

    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _starsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _xpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    ProgressService.completeCourse(widget.courseId, _stars, _xpEarned);

    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _starsCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _animateXP();
    });
  }

  void _animateXP() {
    int current = 0;
    _xpTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      current += (_xpEarned / 40).ceil();
      if (current >= _xpEarned) {
        current = _xpEarned;
        t.cancel();
      }
      if (mounted) setState(() => _displayXP = current);
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _starsCtrl.dispose();
    _xpCtrl.dispose();
    _xpTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = widget.total > 0
        ? (widget.score / widget.total * 100).round()
        : 0;
    final isPerfect = widget.score == widget.total;
    final color = widget.color;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Emoji animé
              ScaleTransition(
                scale: _scaleAnim,
                child: Text(
                  isPerfect ? '🎉' : _stars >= 2 ? '🌟' : '💪',
                  style: const TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isPerfect
                    ? 'Parfait !'
                    : _stars >= 2
                        ? 'Très bien !'
                        : 'Bien joué !',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.courseTitle} · ${widget.languageName}',
                style: const TextStyle(fontSize: 14, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Étoiles
              _StarsRow(stars: _stars, controller: _starsCtrl, color: color),

              const SizedBox(height: 28),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(
                    icon: Icons.percent_rounded,
                    iconColor: color,
                    label: 'Score',
                    value: '$percent%',
                  ),
                  _StatCard(
                    icon: Icons.check_circle_rounded,
                    iconColor: Colors.green,
                    label: 'Bonnes réponses',
                    value: '${widget.score} / ${widget.total}',
                  ),
                  _StatCard(
                    icon: Icons.bolt_rounded,
                    iconColor: Colors.amber,
                    label: 'XP gagnés',
                    value: '+$_displayXP',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Badge if perfect
              if (isPerfect)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.amber.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.military_tech_rounded,
                          color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Badge Score Parfait débloqué !',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),

              if (isPerfect) const SizedBox(height: 20),

              // Progress bar XP
              _XPProgressBar(color: color),

              const SizedBox(height: 28),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Retour à l\'accueil',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.replay_rounded, color: color),
                label: Text(
                  'Recommencer',
                  style: TextStyle(color: color, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stars Row ────────────────────────────────────────────────────────────────

class _StarsRow extends StatelessWidget {
  final int stars;
  final AnimationController controller;
  final Color color;

  const _StarsRow(
      {required this.stars,
      required this.controller,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        final delay = i * 0.25;
        return AnimatedBuilder(
          animation: controller,
          builder: (_, child) {
            final t = ((controller.value - delay) / 0.5).clamp(0.0, 1.0);
            final scale =
                filled ? Curves.elasticOut.transform(t) : 1.0;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? Colors.amber : const Color(0xFFDDD8D0),
              size: 52,
            ),
          ),
        );
      }),
    );
  }
}

// ─── XP Progress Bar ─────────────────────────────────────────────────────────

class _XPProgressBar extends StatefulWidget {
  final Color color;
  const _XPProgressBar({required this.color});

  @override
  State<_XPProgressBar> createState() => _XPProgressBarState();
}

class _XPProgressBarState extends State<_XPProgressBar> {
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
    final level = ProgressService.getUserLevel(_xp);
    final nextXP = ProgressService.xpForNextLevel(_xp);
    final curXP = ProgressService.xpForCurrentLevel(_xp);
    final progress =
        nextXP > curXP ? (_xp - curXP) / (nextXP - curXP) : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ton niveau : $level',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: Colors.amber, size: 16),
                  Text('$_xp XP',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: widget.color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor:
                  widget.color.withValues(alpha: 0.15),
              valueColor:
                  AlwaysStoppedAnimation<Color>(widget.color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_xp / $nextXP XP — prochain niveau',
            style:
                const TextStyle(fontSize: 11, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.grey),
            textAlign: TextAlign.center),
      ],
    );
  }
}

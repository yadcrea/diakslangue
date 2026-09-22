import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;

  Timer? _phraseTimer;
  int _phraseIndex = 0;
  bool _bubbleVisible = true;

  final List<Map<String, String>> _phrases = [
    {'lang': 'Diakhango', 'text': 'Tana manssii !', 'tr': 'Bonjour !'},
    {'lang': 'Diakhango', 'text': 'Ining ségué !', 'tr': 'Bienvenue !'},
    {'lang': 'Sousou',    'text': 'Ikèna !',        'tr': 'Bonjour !'},
    {'lang': 'Wolof',     'text': 'Salaamalekum !', 'tr': 'Bonjour !'},
    {'lang': 'Hausa',     'text': 'Ina kwana !',    'tr': 'Bonjour !'},
    {'lang': 'Yoruba',    'text': 'Ẹ káàárọ̀ !',   'tr': 'Bonjour !'},
    {'lang': 'Lingala',   'text': 'Mbote !',        'tr': 'Bonjour !'},
    {'lang': 'Swahili',   'text': 'Habari !',       'tr': 'Bonjour !'},
    {'lang': 'Mandingo',  'text': 'Fo kumba !',     'tr': 'Bonjour !'},
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0.0, end: -18.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
        _startPhraseTimer();
      }
    });
  }

  void _startPhraseTimer() {
    _phraseTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (!mounted) return;
      setState(() => _bubbleVisible = false);
      Future.delayed(const Duration(milliseconds: 280), () {
        if (!mounted) return;
        setState(() {
          _phraseIndex = (_phraseIndex + 1) % _phrases.length;
          _bubbleVisible = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _phraseTimer?.cancel();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingLanguageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _phrases[_phraseIndex];

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: _WavePainter(),
            child: const SizedBox.expand(),
          ),

          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // Logo
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Diakslangue',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2A4A),
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'Apprends les dialectes africains',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2C4A70),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mascotte animée avec bulle
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Mascotte
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/mascotte.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          // Bulle de dialogue
                          Positioned(
                            top: 20,
                            right: 20,
                            child: AnimatedOpacity(
                              opacity: _bubbleVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: AnimatedScale(
                                scale: _bubbleVisible ? 1.0 : 0.6,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.elasticOut,
                                child: _SpeechBubble(
                                  lang: phrase['lang']!,
                                  text: phrase['text']!,
                                  tr: phrase['tr']!,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bouton Commencer
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ElevatedButton(
                onPressed: _goHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1B2A4A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Commencer',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String lang;
  final String text;
  final String tr;

  const _SpeechBubble({
    required this.lang,
    required this.text,
    required this.tr,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubbleTailPainter(),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150, minWidth: 100),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8EC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8A030), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8A030).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lang.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFFE8A030),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2A4A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Color(0xFF5A6A82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = const Color(0xFFFFF8EC)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFE8A030)
      ..style = PaintingStyle.fill;

    // Triangle border
    final borderPath = Path()
      ..moveTo(20, size.height)
      ..lineTo(36, size.height)
      ..lineTo(28, size.height + 12)
      ..close();
    canvas.drawPath(borderPath, borderPaint);

    // Triangle fill (slightly inset)
    final fillPath = Path()
      ..moveTo(22, size.height - 1)
      ..lineTo(34, size.height - 1)
      ..lineTo(28, size.height + 9)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const darkBlue = Color(0xFF5A95D8);
    const midBlue = Color(0xFF84B6EB);
    const lightBlue = Color(0xFFB8D7F0);

    final bgPaint = Paint()..color = darkBlue;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final wavePaint = Paint()..color = midBlue;
    final wavePath = Path();
    wavePath.moveTo(-size.width * 0.1, size.height * 0.18);
    wavePath.cubicTo(
      size.width * 0.2, size.height * 0.05,
      size.width * 0.6, size.height * 0.10,
      size.width * 1.1, size.height * 0.25,
    );
    wavePath.lineTo(size.width * 1.1, size.height);
    wavePath.lineTo(-size.width * 0.1, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);

    final lightPaint = Paint()..color = lightBlue;
    final lightPath = Path();
    lightPath.moveTo(-size.width * 0.05, size.height * 0.82);
    lightPath.cubicTo(
      size.width * 0.15, size.height * 0.72,
      size.width * 0.45, size.height * 0.78,
      size.width * 0.55, size.height,
    );
    lightPath.lineTo(-size.width * 0.05, size.height);
    lightPath.close();
    canvas.drawPath(lightPath, lightPaint);

    final lightPath2 = Path();
    lightPath2.moveTo(size.width * 0.65, size.height);
    lightPath2.cubicTo(
      size.width * 0.75, size.height * 0.88,
      size.width * 0.92, size.height * 0.85,
      size.width * 1.05, size.height * 0.92,
    );
    lightPath2.lineTo(size.width * 1.05, size.height);
    lightPath2.close();
    canvas.drawPath(lightPath2, lightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

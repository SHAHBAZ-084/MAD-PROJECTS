import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _offsetAnimations;
  late final List<Animation<double>> _fadeAnimations;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;
  late final List<Color> _colors;
  final String _text = 'SplitSmart';
  final List<Offset> _startOffsets = [
    Offset(-2, -2), // S - top left
    Offset(2, -2),  // p - top right
    Offset(-2, 2),  // l - bottom left
    Offset(2, 2),   // i - bottom right
    Offset(-2, 0),  // t - left
    Offset(2, 0),   // S - right
    Offset(0, -2),  // m - top
    Offset(0, 2),   // a - bottom
    Offset(-1.5, 1.5), // r - bottom left
    Offset(1.5, -1.5), // t - top right
  ];

  @override
  void initState() {
    super.initState();
    _colors = [
      Colors.cyanAccent, // S: bright
      Colors.white,
      const Color(0xFF3D5A80), // accent
      Colors.cyanAccent,
      Colors.blueAccent,
      Colors.lightBlueAccent,
      Colors.tealAccent,
      Colors.white,
      Colors.cyanAccent, // r: bright
      Colors.cyan,      // t
    ];
    _controllers = List.generate(_text.length, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    ));
    _offsetAnimations = List.generate(_text.length, (i) => Tween<Offset>(
      begin: _startOffsets[i % _startOffsets.length],
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllers[i],
      curve: Curves.easeOutExpo,
    )));
    _fadeAnimations = List.generate(_text.length, (i) => Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controllers[i],
      curve: Curves.easeIn,
    )));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticInOut),
    );
    _startAnimation();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    });
  }

  Future<void> _startAnimation() async {
    // Animate all letters in within 2.5 seconds
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 250));
    }
    // Wait until all are in
    await Future.delayed(const Duration(milliseconds: 250));
    // Bounce all together for the remaining 2.5 seconds
    _bounceController.repeat(reverse: true, period: const Duration(milliseconds: 700));
    await Future.delayed(const Duration(milliseconds: 2500));
    _bounceController.stop();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001f3f),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glowing curved light arc
            Positioned.fill(
              child: CustomPaint(
                painter: _GlowArcPainter(),
              ),
            ),
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_text.length, (i) {
                    return AnimatedBuilder(
                      animation: _controllers[i],
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimations[i].value,
                          child: Transform.translate(
                            offset: _offsetAnimations[i].value * 60,
                            child: Transform.scale(
                              scale: _controllers[i].isCompleted ? _bounceAnim.value : 1.0,
                              child: Text(
                                _text[i],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 44,
                                  color: _colors[i % _colors.length],
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textWidth = size.width * 0.7;
    final textHeight = size.height * 0.25;
    final arcRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 30),
      width: textWidth,
      height: textHeight,
    );
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyanAccent.withOpacity(0.7),
          Colors.white.withOpacity(0.5),
          Colors.cyanAccent.withOpacity(0.7),
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    // Draw a smooth upper arc from left (S) to right (t)
    canvas.drawArc(arcRect, -pi * 0.80, pi * 0.60, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
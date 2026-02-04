import 'package:flutter/material.dart';
import 'package:oblns/core/theme.dart';
import 'package:oblns/features/auth/presentation/screens/login_screen.dart';
import 'dart:math' as math;

class GlobalSplashScreen extends StatefulWidget {
  const GlobalSplashScreen({super.key});

  @override
  State<GlobalSplashScreen> createState() => _GlobalSplashScreenState();
}

class _GlobalSplashScreenState extends State<GlobalSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..forward();

    _fadeController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background 3D-like Grid/Particles
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_rotationController.value * 2 * math.pi * 0.1)
                  ..rotateY(_rotationController.value * 2 * math.pi * 0.05),
                alignment: Alignment.center,
                child: _buildParticleBackground(),
              );
            },
          ),

          // Main Logo with 3D Float
          FadeTransition(
            opacity: _fadeController,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                CurvedAnimation(
                  parent: _scaleController,
                  curve: Curves.easeOut,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _build3DLogo(),
                  const SizedBox(height: 24),
                  const Text(
                    'oblns',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LIBYAN SPEED',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary.withValues(alpha: 0.8),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 60),
    );
  }

  Widget _buildParticleBackground() {
    return Opacity(
      opacity: 0.2,
      child: CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: _ParticlePainter(),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary;
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

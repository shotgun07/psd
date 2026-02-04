import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0f0c29),
        body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFe94560), Color(0xFFff6b9d)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFe94560).withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_taxi,
                    size: 60,
                    color: Colors.white,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
            const SizedBox(height: 30),
            Text(
                  'OBLNS',
                  style: GoogleFonts.cairo(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.3, duration: 600.ms),
            const SizedBox(height: 10),
            Text(
              'السرعة الليبية',
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Color(0xFFe94560),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
        ),
      ),
    );
  }
}

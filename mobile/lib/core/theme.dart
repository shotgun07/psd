import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Color Palette
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFe94560); // Vibrant Pink/Red
  static const Color secondary = Color(0xFF2962FF); // Deep Blue
  static const Color accent = Color(0xFFFFD600); // Yellow

  // Background colors
  static const Color darkBackground = Color(0xFF0f0c29);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textError = Color(0xFFFF5252);
  static const Color textSuccess = Color(0xFF4CAF50);

  // Glassmorphism tokens
  static const Color glassBase = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x4De94560);
}

/// Consistent spacing system
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Typography scale
class AppTypography {
  static TextStyle displayLarge(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 57,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.25,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle displayMedium(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 45,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle displaySmall(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle headlineLarge(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    return GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: AppColors.textPrimary,
    );
  }
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      error: AppColors.textError,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.textError, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.textError, width: 2),
      ),
      labelStyle: GoogleFonts.cairo(
        color: AppColors.textSecondary,
      ),
      hintStyle: GoogleFonts.cairo(
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
      errorStyle: GoogleFonts.cairo(
        color: AppColors.textError,
        fontSize: 12,
      ),
    ),
  );
}

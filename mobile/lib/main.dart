import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oblns/core/firebase_config.dart';
import 'package:oblns/core/router/app_router.dart';
import 'package:oblns/features/splash/presentation/splash_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseConfig.initialize();

  // Set default currency to Libyan Dinar
  Intl.defaultLocale = 'ar_LY';
  NumberFormat.currency(locale: 'ar_LY', symbol: 'د.ل');

  // Initialize Firebase Messaging for advanced notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground messages
    print('Received message: ${message.notification?.title}');
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0f0c29),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: OBLNSApp()));
}

class OBLNSApp extends ConsumerWidget {
  const OBLNSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'OBLNS - السرعة الليبية',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'LY'), Locale('en', 'US')],
      locale: const Locale('ar', 'LY'),
      theme: _buildTheme(),
      onGenerateRoute: AppRouter.generateRoute,
      home: const SplashWrapper(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFe94560),
      scaffoldBackgroundColor: const Color(0xFF0f0c29),
      fontFamily: GoogleFonts.cairo().fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFe94560),
        secondary: Color(0xFFff6b9d),
        surface: Color(0xFF302b63),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFe94560),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha((0.05 * 255).round()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.cairo(
          color: Colors.white.withAlpha((0.4 * 255).round()),
        ),
      ),
    );
  }
}

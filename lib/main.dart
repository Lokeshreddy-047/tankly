import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_layout.dart';

// 1. Create a global notifier to track the current theme
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(const TanklyApp());
}

class TanklyApp extends StatelessWidget {
  const TanklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Wrap MaterialApp in a listener so it rebuilds when the theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Tankly',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // --- ☀️ PREMIUM LIGHT THEME ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Ultra-light slate
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF334155),
              primary: const Color(0xFF0F172A), // Deep slate text/icons
              secondary: const Color(0xFFF97316), // Vibrant orange accent
              surface: Colors.white,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFFF8FAFC),
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)), // Soft border
              ),
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          // --- 🌙 PREMIUM DARK THEME ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Slate 900
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF38BDF8), // Electric blue for dark mode
              secondary: const Color(0xFFFB923C), // Bright orange accent
              surface: const Color(0xFF1E293B), // Elevated Slate 800 for cards
              background: const Color(0xFF0F172A),
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 4, // Slight shadow in dark mode for depth
              shadowColor: Colors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF334155), width: 1), // Subtle inner border
              ),
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          home: const MainLayout(),
        );
      },
    );
  }
}
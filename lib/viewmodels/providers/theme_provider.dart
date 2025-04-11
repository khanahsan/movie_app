import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Define light and dark themes
  static ThemeData get lightTheme {
    const Color primaryColor = Color(0xFFD32F2F); // Crimson Red
    const Color scaffoldBackground = Color(0xFFFFF6E5); // Soft Ivory
    const Color appBarBackground = Color(0xFFF5E0B7); // Light Gold
    const Color primaryText = Color(0xFF1C2526); // Deep Charcoal
    const Color secondaryText = Color(0xFF5A6A6C); // Muted Charcoal

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: const Color(0xFFD4AF37), // Gold for accents like rating stars
        surface: appBarBackground, // Background for cards, etc.
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: primaryText, // Deep charcoal text/icons
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: appBarBackground,
        selectedItemColor: Color(0xFFFB923C), // Updated to orange
        unselectedItemColor: secondaryText,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: primaryText),
        bodyMedium: TextStyle(color: secondaryText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Crimson Red for buttons
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryColor, width: 2),
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryText, // Deep charcoal for icons
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color primaryColor = Color(0xFFD32F2F); // Crimson Red
    const Color scaffoldBackground = Color(0xFF0A1D37); // Deep Navy Blue
    const Color appBarBackground = Color(0xFF1B2A44); // Slightly lighter navy
    const Color primaryText = Color(0xFFFFF8E1); // Soft Cream
    const Color secondaryText = Color(0xFFB0A992); // Muted Cream

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: Colors.amberAccent, // For accents like rating stars
        surface: appBarBackground, // Background for cards, etc.
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: primaryText, // Soft cream text/icons
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: appBarBackground,
        selectedItemColor: Color(0xFFFB923C), // Updated to orange
        unselectedItemColor: secondaryText,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: primaryText),
        bodyMedium: TextStyle(color: secondaryText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Crimson Red for buttons
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryColor, width: 2),
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: primaryText, // Soft cream for icons
      ),
    );
  }
}

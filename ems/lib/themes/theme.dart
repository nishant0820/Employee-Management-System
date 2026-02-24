import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(String mode) {
    switch (mode) {
      case 'Light Mode':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark Mode':
        _themeMode = ThemeMode.dark;
        break;
      case 'System Default':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
}

class AppTheme {
	AppTheme._();

	static const Color _seedColor = Colors.indigo;

	static ThemeData lightTheme = ThemeData(
		useMaterial3: true,
		brightness: Brightness.light,
		colorScheme: ColorScheme.fromSeed(
			seedColor: _seedColor,
			brightness: Brightness.light,
		),
		scaffoldBackgroundColor: Colors.white,
		appBarTheme: const AppBarTheme(
			centerTitle: true,
			elevation: 0,
		),
		cardTheme: CardThemeData(
			elevation: 1,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(12),
			),
		),
	);

	static ThemeData darkTheme = ThemeData(
		useMaterial3: true,
		brightness: Brightness.dark,
		colorScheme: ColorScheme.fromSeed(
			seedColor: _seedColor,
			brightness: Brightness.dark,
		),
		scaffoldBackgroundColor: Colors.black,
		appBarTheme: const AppBarTheme(
			centerTitle: true,
			elevation: 0,
		),
		cardTheme: CardThemeData(
			elevation: 1,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(12),
			),
		),
	);
}

import 'package:flutter/material.dart';

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
		scaffoldBackgroundColor: const Color(0xFFF8FAFC),
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
		scaffoldBackgroundColor: const Color(0xFF0F172A),
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

import 'package:flutter/material.dart';
import 'package:ems/screens/login_screen.dart';
import 'package:ems/screens/splash_screen.dart';
import 'package:ems/themes/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, child) {
        return MaterialApp(
          title: 'EMS App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeManager().themeMode,
          home: const SplashScreen(nextScreen: LoginScreen()),
        );
      },
    );
  }
}

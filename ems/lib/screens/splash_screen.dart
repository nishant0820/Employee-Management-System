import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ems/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
	const SplashScreen({super.key, required this.nextScreen});

	final Widget nextScreen;

	@override
	State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
	@override
	void initState() {
		super.initState();
		_openNextScreen();
	}

	Future<void> _openNextScreen() async {
		await Future.delayed(const Duration(seconds: 2));
		if (!mounted) return;

		final prefs = await SharedPreferences.getInstance();
		final authToken = prefs.getString('auth_token');
		final loginTimeStr = prefs.getString('login_time');

		Widget targetScreen = widget.nextScreen; // Default fallback

		if (authToken != null && authToken.isNotEmpty && loginTimeStr != null) {
			try {
				final loginTime = DateTime.parse(loginTimeStr);
				final difference = DateTime.now().difference(loginTime);
				
				// Keep logged in if under 12 hours
				if (difference.inHours < 12) {
					targetScreen = const MainScreen();
				} else {
					// Session expired
					await prefs.remove('auth_token');
					await prefs.remove('login_time');
				}
			} catch (e) {
				// Parse error, clear token
				await prefs.remove('auth_token');
				await prefs.remove('login_time');
			}
		}

		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (_) => targetScreen),
		);
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.apartment,
							size: 84,
							color: colorScheme.primary,
						),
						const SizedBox(height: 16),
						Text(
							'EMS Portal',
							style: Theme.of(context).textTheme.headlineSmall,
						),
						const SizedBox(height: 8),
						Text(
							'Employee Management System',
							style: Theme.of(context).textTheme.bodyMedium,
						),
					],
				),
			),
		);
	}
}

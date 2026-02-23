import 'package:flutter/material.dart';

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

		Navigator.of(context).pushReplacement(
			MaterialPageRoute(builder: (_) => widget.nextScreen),
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

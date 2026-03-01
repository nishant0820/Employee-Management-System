import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ems/screens/main_screen.dart';
import 'package:ems/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
	const LoginScreen({super.key});

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	bool _obscurePassword = true;
	bool _isLoading = false;

	String? _selectedDepartment = 'HR';
	final List<String> _departments = ['HR', 'Admin', 'Employee'];

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _login() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() => _isLoading = true);

		try {
			String baseUrl = 'https://employee-management-system-tefv.onrender.com';
			if (!kIsWeb) {
				if (Platform.isAndroid) {
					baseUrl = 'https://employee-management-system-tefv.onrender.com'; // Or 10.0.2.2 usually
				}
			}

			final response = await http.post(
				Uri.parse('$baseUrl/api/auth/login'),
				headers: {
					'Content-Type': 'application/json',
				},
				body: json.encode({
					'email': _emailController.text.trim(),
					'password': _passwordController.text,
					'department': _selectedDepartment,
				}),
			);

			if (!mounted) return;

			if (response.statusCode == 200) {
				// Parse login response
				final responseData = json.decode(response.body);
				String token = responseData['token'];
				String department = responseData['department'];
				String fullName = responseData['fullName'] ?? 'User';
				String email = responseData['email'] ?? '';
				String phone = responseData['phoneNumber'] ?? '';

				// Save the token persistently
				final prefs = await SharedPreferences.getInstance();
				await prefs.setString('auth_token', token);
				await prefs.setString('user_role', department); // Mapping abstract db role to the frontend session variable
				await prefs.setString('full_name', fullName);
				await prefs.setString('user_email', email);
				await prefs.setString('user_phone', phone);
				await prefs.setBool('is_new_user', false);
				
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Login successful!'),
						backgroundColor: Colors.green,
					),
				);
				
				Navigator.of(context).pushReplacement(
					MaterialPageRoute(builder: (_) => const MainScreen()),
				);
			} else {
				final responseData = json.decode(response.body);
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(responseData['message'] ?? 'Login failed'),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (error) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Error: Could not connect to the server.'),
					backgroundColor: Colors.red,
				),
			);
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.all(24.0),
						child: Form(
							key: _formKey,
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									// Header Image or Icon
									Icon(
										Icons.lock_person,
										size: 80,
										color: colorScheme.primary,
									),
									const SizedBox(height: 16),
									Text(
										'Welcome Back',
										style: Theme.of(context).textTheme.headlineMedium?.copyWith(
													fontWeight: FontWeight.bold,
												),
										textAlign: TextAlign.center,
									),
									const SizedBox(height: 8),
									Text(
										'Log in to your HR Dashboard',
										style: Theme.of(context).textTheme.bodyMedium?.copyWith(
													color: colorScheme.onSurfaceVariant,
												),
										textAlign: TextAlign.center,
									),
									const SizedBox(height: 32),
									
									// Email Address
									TextFormField(
										controller: _emailController,
										keyboardType: TextInputType.emailAddress,
										decoration: const InputDecoration(
											labelText: 'Email Address',
											prefixIcon: Icon(Icons.email_outlined),
											border: OutlineInputBorder(),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Please enter your email';
											}
											if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
												return 'Please enter a valid email address';
											}
											return null;
										},
									),
									const SizedBox(height: 16),

									// Department Selection
									DropdownButtonFormField<String>(
										value: _selectedDepartment,
										decoration: const InputDecoration(
											labelText: 'Department',
											prefixIcon: Icon(Icons.badge_outlined),
											border: OutlineInputBorder(),
										),
										items: _departments
												.map((dept) => DropdownMenuItem(
															value: dept,
															child: Text(dept),
														))
												.toList(),
										onChanged: (value) {
											if (value == null) return;
											setState(() => _selectedDepartment = value);
										},
									),
									const SizedBox(height: 16),

									// Password
									TextFormField(
										controller: _passwordController,
										obscureText: _obscurePassword,
										decoration: InputDecoration(
											labelText: 'Password',
											prefixIcon: const Icon(Icons.lock_outline),
											suffixIcon: IconButton(
												icon: Icon(
													_obscurePassword ? Icons.visibility_off : Icons.visibility,
												),
												onPressed: () {
													setState(() {
														_obscurePassword = !_obscurePassword;
													});
												},
											),
											border: const OutlineInputBorder(),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Please enter your password';
											}
											return null;
										},
									),
									const SizedBox(height: 24),

									// Login Button
									FilledButton(
										onPressed: _isLoading ? null : _login,
										style: FilledButton.styleFrom(
											padding: const EdgeInsets.symmetric(vertical: 16),
										),
										child: _isLoading 
											? const SizedBox(
												height: 20, 
												width: 20, 
												child: CircularProgressIndicator(strokeWidth: 2)
											  )
											: const Text('Log In', style: TextStyle(fontSize: 16)),
									),
									const SizedBox(height: 16),

									// Signup Navigation Button
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											const Text("Don't have an account?"),
											TextButton(
												onPressed: () {
													Navigator.of(context).push(
														MaterialPageRoute(builder: (_) => const SignupScreen())
													);
												},
												child: const Text('Sign Up'),
											),
										],
									),
								],
							),
						),
					),
				),
			),
		);
	}
}

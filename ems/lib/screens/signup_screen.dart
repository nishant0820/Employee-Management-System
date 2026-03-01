import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ems/screens/main_screen.dart';

class SignupScreen extends StatefulWidget {
	const SignupScreen({super.key});

	@override
	State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
	final _formKey = GlobalKey<FormState>();
	final _fullNameController = TextEditingController();
	final _emailController = TextEditingController();
	final _phoneController = TextEditingController();
	final _companyController = TextEditingController();
	final _passwordController = TextEditingController();
	final _confirmPasswordController = TextEditingController();

	bool _obscurePassword = true;
	bool _obscureConfirmPassword = true;

	String? _selectedDepartment = 'HR';
	final List<String> _departments = ['HR', 'Admin', 'Employee'];

	@override
	void dispose() {
		_fullNameController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_companyController.dispose();
		_passwordController.dispose();
		_confirmPasswordController.dispose();
		super.dispose();
	}

	Future<void> _signup() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (context) => const Center(
				child: CircularProgressIndicator(),
			),
		);

		try {
			String baseUrl = 'https://employee-management-system-tefv.onrender.com/';
			if (!kIsWeb) {
				if (Platform.isAndroid) {
					baseUrl = 'https://employee-management-system-tefv.onrender.com/'; // Or 10.0.2.2 usually
				}
			}

			final response = await http.post(
				Uri.parse('$baseUrl/api/auth/register'),
				headers: {
					'Content-Type': 'application/json',
				},
				body: json.encode({
					'fullName': _fullNameController.text.trim(),
					'email': _emailController.text.trim(),
					'phoneNumber': _phoneController.text.trim(),
					'company': _companyController.text.trim(),
					'department': _selectedDepartment,
					'password': _passwordController.text,
				}),
			);

			if (!mounted) return;
			Navigator.of(context).pop(); // Close dialog

			if (response.statusCode == 201) {

				final responseData = json.decode(response.body);
				String token = responseData['token'];
				String department = responseData['department'];
				String fullName = responseData['fullName'] ?? _fullNameController.text.trim();
				String email = responseData['email'] ?? '';
				String phone = responseData['phoneNumber'] ?? '';

				// Save the token persistently
				final prefs = await SharedPreferences.getInstance();
				await prefs.setString('auth_token', token);
				await prefs.setString('user_role', department);
				await prefs.setString('full_name', fullName);
				await prefs.setString('user_email', email);
				await prefs.setString('user_phone', phone);
				await prefs.setBool('is_new_user', true);

				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Account created successfully!'),
						backgroundColor: Colors.green,
					),
				);
				// Route directly to Main HR Dashboard
				Navigator.of(context).pushReplacement(
					MaterialPageRoute(builder: (_) => const MainScreen()),
				);
			} else {
				final responseData = json.decode(response.body);
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(responseData['message'] ?? 'Failed to create account'),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (error) {
			if (!mounted) return;
			Navigator.of(context).pop();

			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Error: Could not connect to the server.'),
					backgroundColor: Colors.red,
				),
			);
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
										Icons.admin_panel_settings,
										size: 80,
										color: colorScheme.primary,
									),
									const SizedBox(height: 16),
									Text(
										'Create Account',
										style: Theme.of(context).textTheme.headlineMedium?.copyWith(
													fontWeight: FontWeight.bold,
												),
										textAlign: TextAlign.center,
									),
									const SizedBox(height: 8),
									Text(
										'Sign up to manage your employees efficiently',
										style: Theme.of(context).textTheme.bodyMedium?.copyWith(
													color: colorScheme.onSurfaceVariant,
												),
										textAlign: TextAlign.center,
									),
									const SizedBox(height: 32),
									
									// Full Name
									TextFormField(
										controller: _fullNameController,
										decoration: const InputDecoration(
											labelText: 'Full Name',
											prefixIcon: Icon(Icons.person_outline),
											border: OutlineInputBorder(),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Please enter your full name';
											}
											return null;
										},
									),
									const SizedBox(height: 16),

									// Company Name
									TextFormField(
										controller: _companyController,
										decoration: const InputDecoration(
											labelText: 'Company/Organization Name',
											prefixIcon: Icon(Icons.business_outlined),
											border: OutlineInputBorder(),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Please enter your company name';
											}
											return null;
										},
									),
									const SizedBox(height: 16),

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
												return 'Please enter an email address';
											}
											if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
												return 'Please enter a valid email address';
											}
											return null;
										},
									),
									const SizedBox(height: 16),

									// Phone Number
									TextFormField(
										controller: _phoneController,
										keyboardType: TextInputType.phone,
										decoration: const InputDecoration(
											labelText: 'Phone Number',
											prefixIcon: Icon(Icons.phone_outlined),
											border: OutlineInputBorder(),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Please enter a phone number';
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
												return 'Please enter a password';
											}
											if (value.length < 6) {
												return 'Password must be at least 6 characters';
											}
											return null;
										},
									),
									const SizedBox(height: 16),

									// Confirm Password
									TextFormField(
										controller: _confirmPasswordController,
										obscureText: _obscureConfirmPassword,
										decoration: InputDecoration(
											labelText: 'Confirm Password',
											prefixIcon: const Icon(Icons.lock_outline),
											suffixIcon: IconButton(
												icon: Icon(
													_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
												),
												onPressed: () {
													setState(() {
														_obscureConfirmPassword = !_obscureConfirmPassword;
													});
												},
											),
											border: const OutlineInputBorder(),
										),
										validator: (value) {
											if (value == null || value.trim().isEmpty) {
												return 'Please confirm your password';
											}
											if (value != _passwordController.text) {
												return 'Passwords do not match';
											}
											return null;
										},
									),
									const SizedBox(height: 24),

									// Sign Up Button
									FilledButton(
										onPressed: _signup,
										style: FilledButton.styleFrom(
											padding: const EdgeInsets.symmetric(vertical: 16),
										),
										child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
									),
									const SizedBox(height: 16),

									// Login Navigation Button
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											const Text('Already have an account?'),
											TextButton(
												onPressed: () {
													// Usually we pop to return to the previously opened Login screen
													Navigator.of(context).pop();
												},
												child: const Text('Log In'),
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

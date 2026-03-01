import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:ems/widgets/gradient_button.dart';

class EditProfileScreen extends StatefulWidget {
	const EditProfileScreen({super.key});

	@override
	State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
	final _formKey = GlobalKey<FormState>();
	final _nameController = TextEditingController();
	final _emailController = TextEditingController();
	final _phoneController = TextEditingController();
	final _employeeIdController = TextEditingController();
	final _departmentController = TextEditingController();
	final _roleController = TextEditingController();

	bool _isLoading = false;

	@override
	void initState() {
		super.initState();
		_loadProfileData();
	}

	Future<void> _loadProfileData() async {
		final prefs = await SharedPreferences.getInstance();
		final fullName = prefs.getString('full_name') ?? '';
		final email = prefs.getString('user_email') ?? '';
		final phone = prefs.getString('user_phone') ?? '';
		final department = prefs.getString('user_department') ?? '';
		final role = prefs.getString('user_role') ?? '';

		if (mounted) {
			setState(() {
				_nameController.text = fullName;
				_emailController.text = email;
				_phoneController.text = phone;
				_departmentController.text = department;
				_roleController.text = role;
			});
		}
	}

	@override
	void dispose() {
		_nameController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_employeeIdController.dispose();
		_departmentController.dispose();
		_roleController.dispose();
		super.dispose();
	}

	Future<void> _saveProfile() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() => _isLoading = true);

		try {
			final prefs = await SharedPreferences.getInstance();
			final authToken = prefs.getString('auth_token');

			if (authToken != null && authToken.isNotEmpty) {
				String baseUrl = 'https://employee-management-system-tefv.onrender.com';
				if (!kIsWeb) {
					if (Platform.isAndroid) {
						baseUrl = 'https://employee-management-system-tefv.onrender.com';
					}
				}

				final response = await http.put(
					Uri.parse('$baseUrl/api/auth/me'),
					headers: {
						'Content-Type': 'application/json',
						'Authorization': 'Bearer $authToken',
					},
					body: json.encode({
						'fullName': _nameController.text.trim(),
						'email': _emailController.text.trim(),
						'phoneNumber': _phoneController.text.trim(),
					}),
				);

				if (!mounted) return;

				if (response.statusCode == 200) {
					final updatedData = json.decode(response.body);
					
					// Update local cache
					await prefs.setString('full_name', updatedData['fullName'] ?? '');
					await prefs.setString('user_email', updatedData['email'] ?? '');
					await prefs.setString('user_phone', updatedData['phoneNumber'] ?? '');

					ScaffoldMessenger.of(context).showSnackBar(
						const SnackBar(
							content: Text('Profile updated successfully'),
							backgroundColor: Colors.green,
							behavior: SnackBarBehavior.floating,
						),
					);
					
					Navigator.of(context).pop();
				} else {
					final errorData = json.decode(response.body);
					ScaffoldMessenger.of(context).showSnackBar(
						SnackBar(
							content: Text(errorData['message'] ?? 'Failed to update profile'),
							backgroundColor: Colors.red,
							behavior: SnackBarBehavior.floating,
						),
					);
				}
			}
		} catch (error) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Error connecting to server.'),
					backgroundColor: Colors.red,
					behavior: SnackBarBehavior.floating,
				),
			);
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		final avatarLabel = _nameController.text.trim().isEmpty
				? '?'
				: _nameController.text.trim().substring(0, 1).toUpperCase();

		return Scaffold(
			appBar: AppBar(
				title: const Text('Edit Profile'),
				actions: [
					TextButton(
						onPressed: _isLoading ? null : _saveProfile,
						child: const Text('Save'),
					),
				],
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Center(
								child: Stack(
									children: [
										CircleAvatar(
											radius: 50,
											backgroundColor: colorScheme.primaryContainer,
											child: Text(
												avatarLabel,
												style: TextStyle(
													color: colorScheme.onPrimaryContainer,
													fontSize: 36,
													fontWeight: FontWeight.w600,
												),
											),
										),
										Positioned(
											bottom: 0,
											right: 0,
											child: Container(
												padding: const EdgeInsets.all(6),
												decoration: BoxDecoration(
													color: colorScheme.primary,
													shape: BoxShape.circle,
													border: Border.all(
														color: colorScheme.surface,
														width: 2,
													),
												),
												child: Icon(
													Icons.camera_alt,
													size: 18,
													color: colorScheme.onPrimary,
												),
											),
										),
									],
								),
							),
							const SizedBox(height: 8),
							Center(
								child: TextButton.icon(
									onPressed: () {
										// Handle photo change
									},
									icon: const Icon(Icons.edit, size: 16),
									label: const Text('Change Photo'),
								),
							),
							const SizedBox(height: 24),
							Text(
								'Personal Information',
								style: Theme.of(context).textTheme.titleLarge,
							),
							const SizedBox(height: 12),
							_InputField(
								controller: _nameController,
								label: 'Full Name',
								icon: Icons.person_outline,
								validator: (value) {
									if (value == null || value.trim().isEmpty) {
										return 'Name is required';
									}
									return null;
								},
							),
							const SizedBox(height: 16),
							_InputField(
								controller: _emailController,
								label: 'Email Address',
								icon: Icons.email_outlined,
								keyboardType: TextInputType.emailAddress,
								validator: (value) {
									if (value == null || value.trim().isEmpty) {
										return 'Email is required';
									}
									if (!value.contains('@')) {
										return 'Enter a valid email';
									}
									return null;
								},
							),
							const SizedBox(height: 16),
							_InputField(
								controller: _phoneController,
								label: 'Phone Number',
								icon: Icons.phone_outlined,
								keyboardType: TextInputType.phone,
								validator: (value) {
									if (value == null || value.trim().isEmpty) {
										return 'Phone number is required';
									}
									return null;
								},
							),
							const SizedBox(height: 24),
							Text(
								'Work Information',
								style: Theme.of(context).textTheme.titleLarge,
							),
							const SizedBox(height: 12),
							_InputField(
								controller: _employeeIdController,
								label: 'Employee ID',
								icon: Icons.badge_outlined,
								enabled: false,
							),
							const SizedBox(height: 16),
							_InputField(
								controller: _departmentController,
								label: 'Department',
								icon: Icons.apartment_outlined,
								enabled: false, // Made uneditable
							),
							const SizedBox(height: 16),
							_InputField(
								controller: _roleController,
								label: 'Role',
								icon: Icons.work_outline,
								enabled: false, // Made uneditable
							),
							const SizedBox(height: 32),
							GradientButton(
								label: _isLoading ? 'Saving...' : 'Save Changes',
								icon: Icons.check,
								onPressed: _isLoading ? null : _saveProfile,
							),
							const SizedBox(height: 12),
							SizedBox(
								width: double.infinity,
								child: OutlinedButton.icon(
									onPressed: _isLoading
											? null
											: () => Navigator.of(context).pop(),
									icon: const Icon(Icons.close),
									label: const Text('Cancel'),
								),
							),
						],
					),
				),
			),
		);
	}
}

class _InputField extends StatelessWidget {
	const _InputField({
		required this.controller,
		required this.label,
		required this.icon,
		this.validator,
		this.keyboardType,
		this.enabled = true,
	});

	final TextEditingController controller;
	final String label;
	final IconData icon;
	final String? Function(String?)? validator;
	final TextInputType? keyboardType;
	final bool enabled;

	@override
	Widget build(BuildContext context) {
		return TextFormField(
			controller: controller,
			decoration: InputDecoration(
				labelText: label,
				prefixIcon: Icon(icon),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
				),
				filled: true,
				enabled: enabled,
			),
			keyboardType: keyboardType,
			validator: validator,
		);
	}
}

class _DropdownField extends StatelessWidget {
	const _DropdownField({
		required this.value,
		required this.label,
		required this.icon,
		required this.items,
		required this.onChanged,
		this.validator,
	});

	final String? value;
	final String label;
	final IconData icon;
	final List<String> items;
	final void Function(String?) onChanged;
	final String? Function(String?)? validator;

	@override
	Widget build(BuildContext context) {
		return DropdownButtonFormField<String>(
			value: value,
			decoration: InputDecoration(
				labelText: label,
				prefixIcon: Icon(icon),
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
				),
				filled: true,
			),
			items: items.map((item) {
				return DropdownMenuItem<String>(
					value: item,
					child: Text(item),
				);
			}).toList(),
			onChanged: onChanged,
			validator: validator,
		);
	}
}

import 'package:flutter/material.dart';
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

	String? _selectedRole;
	String? _selectedDepartment;
	bool _isLoading = false;

	final List<String> _roles = [];

	final List<String> _departments = [];

	@override
	void dispose() {
		_nameController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_employeeIdController.dispose();
		super.dispose();
	}

	Future<void> _saveProfile() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() => _isLoading = true);

		// Simulate API call
		await Future.delayed(const Duration(seconds: 1));

		if (mounted) {
			setState(() => _isLoading = false);
			
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Profile updated successfully'),
					behavior: SnackBarBehavior.floating,
				),
			);
			
			Navigator.of(context).pop();
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
							_DropdownField(
								value: _selectedRole,
								label: 'Role',
								icon: Icons.work_outline,
								items: _roles,
								onChanged: (value) {
									setState(() => _selectedRole = value);
								},
								validator: (value) {
									if (value == null || value.isEmpty) {
										return 'Role is required';
									}
									return null;
								},
							),
							const SizedBox(height: 16),
							_DropdownField(
								value: _selectedDepartment,
								label: 'Department',
								icon: Icons.apartment_outlined,
								items: _departments,
								onChanged: (value) {
									setState(() => _selectedDepartment = value);
								},
								validator: (value) {
									if (value == null || value.isEmpty) {
										return 'Department is required';
									}
									return null;
								},
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

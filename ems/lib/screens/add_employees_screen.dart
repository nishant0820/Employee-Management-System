import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AddEmployeesScreen extends StatefulWidget {
	const AddEmployeesScreen({super.key});

	@override
	State<AddEmployeesScreen> createState() => _AddEmployeesScreenState();
}

class _AddEmployeesScreenState extends State<AddEmployeesScreen> {
	final _formKey = GlobalKey<FormState>();
	final _fullNameController = TextEditingController();
	final _emailController = TextEditingController();
	final _phoneController = TextEditingController();
	final _employeeIdController = TextEditingController();

	String? _selectedDepartment;
	String? _selectedRole;
	String? _selectedStatus = 'Active';

	final List<String> _departments = [
		'Engineering',
		'HR',
		'Sales',
		'Marketing',
		'Finance'
	];

	final List<String> _roles = [
		'Developer',
		'Manager',
		'Designer',
		'Analyst',
		'Tester'
	];

	final List<String> _statusOptions = [
		'Active',
		'Inactive',
		'On Leave'
	];

	@override
	void dispose() {
		_fullNameController.dispose();
		_emailController.dispose();
		_phoneController.dispose();
		_employeeIdController.dispose();
		super.dispose();
	}

	String? _requiredValidator(String? value, String label) {
		if (value == null || value.trim().isEmpty) {
			return 'Please enter $label';
		}
		return null;
	}

	String? _emailValidator(String? value) {
		if (value == null || value.trim().isEmpty) {
			return 'Please enter an email address';
		}
		final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
		if (!emailRegex.hasMatch(value)) {
			return 'Enter a valid email address';
		}
		return null;
	}

	String? _phoneValidator(String? value) {
		if (value == null || value.trim().isEmpty) {
			return 'Please enter a phone number';
		}
		if (value.replaceAll(RegExp(r'\D'), '').length < 10) {
			return 'Enter a valid phone number';
		}
		return null;
	}

	Future<void> _saveEmployee() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		if (_selectedDepartment == null || _selectedRole == null) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Please select department and role'),
				),
			);
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
			String baseUrl = 'http://192.168.29.22:5000';
			if (!kIsWeb) {
				if (Platform.isAndroid) {
					// Use your local Wi-Fi IP address for Android real devices
					baseUrl = 'http://192.168.29.22:5000';
				}
			}

			final response = await http.post(
				Uri.parse('$baseUrl/api/employees'),
				headers: {
					'Content-Type': 'application/json',
				},
				body: json.encode({
					'fullName': _fullNameController.text.trim(),
					'email': _emailController.text.trim(),
					'phone': _phoneController.text.trim(),
					'employeeId': _employeeIdController.text.trim(),
					'department': _selectedDepartment,
					'role': _selectedRole,
					'status': _selectedStatus ?? 'Active',
				}),
			);

			if (!mounted) return;

			// Close loading dialog
			Navigator.of(context).pop();

			if (response.statusCode == 201) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Employee added successfully'),
						backgroundColor: Colors.green,
					),
				);
				// Go back to previous screen
				Navigator.of(context).pop();
			} else {
				final responseData = json.decode(response.body);
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text(responseData['message'] ?? 'Failed to add employee'),
						backgroundColor: Colors.red,
					),
				);
			}
		} catch (error) {
			if (!mounted) return;
			// Close loading dialog
			Navigator.of(context).pop();
			
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('Error: Could not connect to the server. Check if backend is running.'),
					backgroundColor: Colors.red,
				),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			appBar: AppBar(
				title: const Text('Add Employee'),
				centerTitle: true,
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Card(
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: Row(
										children: [
											CircleAvatar(
												radius: 28,
												backgroundColor: colorScheme.primaryContainer,
												child: Icon(
													Icons.person_add_alt_1,
													color: colorScheme.onPrimaryContainer,
													size: 28,
												),
											),
											const SizedBox(width: 16),
											Expanded(
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text(
															'Employee Details',
															style: Theme.of(context).textTheme.titleLarge,
														),
														const SizedBox(height: 4),
														Text(
															'Fill in the new employee information',
															style: Theme.of(context).textTheme.bodySmall,
														),
													],
												),
											),
										],
									),
								),
							),
							const SizedBox(height: 20),
							Text(
								'Personal Information',
								style: Theme.of(context).textTheme.titleMedium,
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _fullNameController,
								validator: (value) => _requiredValidator(value, 'full name'),
								decoration: const InputDecoration(
									labelText: 'Full Name',
									prefixIcon: Icon(Icons.person_outline),
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _emailController,
								validator: _emailValidator,
								keyboardType: TextInputType.emailAddress,
								decoration: const InputDecoration(
									labelText: 'Email Address',
									prefixIcon: Icon(Icons.email_outlined),
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _phoneController,
								validator: _phoneValidator,
								keyboardType: TextInputType.phone,
								decoration: const InputDecoration(
									labelText: 'Phone Number',
									prefixIcon: Icon(Icons.phone_outlined),
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 12),
							TextFormField(
								controller: _employeeIdController,
								validator: (value) => _requiredValidator(value, 'employee ID'),
								decoration: const InputDecoration(
									labelText: 'Employee ID',
									prefixIcon: Icon(Icons.badge_outlined),
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 20),
							Text(
								'Work Information',
								style: Theme.of(context).textTheme.titleMedium,
							),
							const SizedBox(height: 12),
							DropdownButtonFormField<String>(
								value: _selectedDepartment,
								decoration: const InputDecoration(
									labelText: 'Department',
									prefixIcon: Icon(Icons.apartment_outlined),
									border: OutlineInputBorder(),
								),
								items: _departments
										.map((dept) => DropdownMenuItem(
													value: dept,
													child: Text(dept),
												))
										.toList(),
								onChanged: (value) {
									setState(() => _selectedDepartment = value);
								},
								validator: (value) {
									if (value == null || value.isEmpty) {
										return 'Please select a department';
									}
									return null;
								},
							),
							const SizedBox(height: 12),
							DropdownButtonFormField<String>(
								value: _selectedRole,
								decoration: const InputDecoration(
									labelText: 'Role',
									prefixIcon: Icon(Icons.work_outline),
									border: OutlineInputBorder(),
								),
								items: _roles
										.map((role) => DropdownMenuItem(
													value: role,
													child: Text(role),
												))
										.toList(),
								onChanged: (value) {
									setState(() => _selectedRole = value);
								},
								validator: (value) {
									if (value == null || value.isEmpty) {
										return 'Please select a role';
									}
									return null;
								},
							),
							const SizedBox(height: 12),
							DropdownButtonFormField<String>(
								value: _selectedStatus,
								decoration: const InputDecoration(
									labelText: 'Status',
									prefixIcon: Icon(Icons.verified_user_outlined),
									border: OutlineInputBorder(),
								),
								items: _statusOptions
										.map((status) => DropdownMenuItem(
													value: status,
													child: Text(status),
												))
										.toList(),
								onChanged: (value) {
									if (value == null) return;
									setState(() => _selectedStatus = value);
								},
							),
							const SizedBox(height: 24),
							SizedBox(
								width: double.infinity,
								child: FilledButton.icon(
									onPressed: _saveEmployee,
									icon: const Icon(Icons.save),
									label: const Text('Add Employee'),
									style: FilledButton.styleFrom(
										padding: const EdgeInsets.symmetric(vertical: 16),
									),
								),
							),
						],
					),
				),
			),
		);
	}
}

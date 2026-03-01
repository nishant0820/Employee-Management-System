import 'package:flutter/material.dart';
import 'package:ems/screens/add_employees_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class EmployeesScreen extends StatefulWidget {
	const EmployeesScreen({super.key});

	@override
	State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
	late final TextEditingController _searchController;
	String _searchText = '';
	String _statusFilter = 'All';
	String _departmentFilter = 'All';
	bool _sortAscending = true;
	bool _isLoading = true;
	List<Employee> _employees = [];

	@override
	void initState() {
		super.initState();
		_searchController = TextEditingController();
		_fetchEmployees();
	}

	Future<void> _fetchEmployees() async {
		setState(() {
			_isLoading = true;
		});

		try {
			String baseUrl = 'https://employee-management-system-tefv.onrender.com';
			if (!kIsWeb) {
				if (Platform.isAndroid) {
					baseUrl = 'https://employee-management-system-tefv.onrender.com';
				}
			}

			final response = await http.get(Uri.parse('$baseUrl/api/employees'));

			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				setState(() {
					_employees = data.map((json) => Employee.fromJson(json)).toList();
					_isLoading = false;
				});
			} else {
				setState(() {
					_isLoading = false;
				});
				if (mounted) {
					ScaffoldMessenger.of(context).showSnackBar(
						const SnackBar(content: Text('Failed to load employees'), backgroundColor: Colors.red),
					);
				}
			}
		} catch (error) {
			setState(() {
				_isLoading = false;
			});
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Error: Could not connect to the server'), backgroundColor: Colors.red),
				);
			}
		}
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	List<Employee> get _filteredEmployees {
		Iterable<Employee> result = _employees;

		if (_searchText.trim().isNotEmpty) {
			final query = _searchText.trim().toLowerCase();
			result = result.where(
				(employee) =>
					employee.name.toLowerCase().contains(query) ||
					employee.role.toLowerCase().contains(query) ||
					employee.department.toLowerCase().contains(query),
			);
		}

		if (_statusFilter != 'All') {
			result = result.where(
				(employee) => employee.status == _statusFilter,
			);
		}

		if (_departmentFilter != 'All') {
			result = result.where((employee) => employee.department == _departmentFilter);
		}

		final list = result.toList();

		return list;
	}

	List<String> get _departments {
		final values = _employees.map((employee) => employee.department).toSet().toList()
			..sort();
		return ['All', ...values];
	}

	@override
	Widget build(BuildContext context) {
		final totalEmployees = _employees.length;
		final activeEmployees = _employees.where((employee) => employee.status == 'Active').length;
		final inactiveEmployees = _employees.where((employee) => employee.status == 'Inactive').length;
		final onLeaveEmployees = _employees.where((employee) => employee.status == 'On Leave').length;
		final filteredEmployees = _filteredEmployees;

		if (_isLoading) {
			return const Center(child: CircularProgressIndicator());
		}

		return Column(
			children: [
				Padding(
					padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
					child: TextField(
						controller: _searchController,
						onChanged: (value) {
							setState(() => _searchText = value);
						},
						decoration: InputDecoration(
							hintText: 'Search employees...',
							prefixIcon: const Icon(Icons.search),
							suffixIcon: _searchText.isEmpty
									? null
									: IconButton(
											onPressed: () {
												_searchController.clear();
												setState(() => _searchText = '');
											},
											icon: const Icon(Icons.close),
										),
							filled: true,
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide.none,
							),
						),
					),
				),
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16),
					child: SingleChildScrollView(
						scrollDirection: Axis.horizontal,
						child: Row(
							children: [
								ChoiceChip(
									label: const Text('All Status'),
									selected: _statusFilter == 'All',
									onSelected: (_) {
										setState(() => _statusFilter = 'All');
									},
								),
								const SizedBox(width: 8),
								ChoiceChip(
									label: const Text('Active'),
									selected: _statusFilter == 'Active',
									onSelected: (_) {
										setState(() => _statusFilter = 'Active');
									},
								),
								const SizedBox(width: 8),
								ChoiceChip(
									label: const Text('Inactive'),
									selected: _statusFilter == 'Inactive',
									onSelected: (_) {
										setState(() => _statusFilter = 'Inactive');
									},
								),
								const SizedBox(width: 8),
								ChoiceChip(
									label: const Text('On Leave'),
									selected: _statusFilter == 'On Leave',
									onSelected: (_) {
										setState(() => _statusFilter = 'On Leave');
									},
								),
							],
						),
					),
				),
				const SizedBox(height: 8),
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16),
					child: SingleChildScrollView(
						scrollDirection: Axis.horizontal,
						child: Row(
							children: _departments
									.map(
										(department) => Padding(
											padding: const EdgeInsets.only(right: 8),
											child: ChoiceChip(
												label: Text(department),
												selected: _departmentFilter == department,
												onSelected: (_) {
													setState(() => _departmentFilter = department);
												},
											),
										),
									)
									.toList(),
						),
					),
				),
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
					child: Row(
						children: [
							Expanded(
								child: _MiniStatCard(
									title: 'Total',
									value: '$totalEmployees',
									icon: Icons.groups_2_outlined,
								),
							),
							SizedBox(width: 6),
							Expanded(
								child: _MiniStatCard(
									title: 'Active',
									value: '$activeEmployees',
									icon: Icons.verified_user_outlined,
								),
							),
							SizedBox(width: 6),
							Expanded(
								child: _MiniStatCard(
									title: 'Inactive',
									value: '$inactiveEmployees',
									icon: Icons.person_off_outlined,
								),
							),
							SizedBox(width: 6),
							Expanded(
								child: _MiniStatCard(
									title: 'On Leave',
									value: '$onLeaveEmployees',
									icon: Icons.event_busy_outlined,
								),
							),
						],
					),
				),
				Padding(
					padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
					child: FilledButton.icon(
						onPressed: () async {
							final result = await Navigator.of(context).push(
								MaterialPageRoute(
									builder: (_) => const AddEmployeesScreen(),
								),
							);
							
							// Refresh list when coming back
							_fetchEmployees();
						},
						icon: const Icon(Icons.person_add_alt_1),
						label: const Text('Add Employee'),
					),
				),
				Expanded(
					child: filteredEmployees.isEmpty
							? Center(
									child: Text(
										'No employees found for selected filters.',
										style: Theme.of(context).textTheme.bodyMedium,
									),
								)
							: ListView.separated(
									padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
									itemCount: filteredEmployees.length,
									separatorBuilder: (_, __) => const SizedBox(height: 10),
									itemBuilder: (context, index) {
										final employee = filteredEmployees[index];
										return _EmployeeCard(employee: employee);
									},
								),
				),
			],
		);
	}
}

class _MiniStatCard extends StatelessWidget {
	const _MiniStatCard({
		required this.title,
		required this.value,
		required this.icon,
	});

	final String title;
	final String value;
	final IconData icon;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Card(
			child: Padding(
				padding: const EdgeInsets.all(12),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Icon(icon, color: colorScheme.primary),
						const SizedBox(height: 8),
						Text(value, style: Theme.of(context).textTheme.titleLarge),
						Text(title, style: Theme.of(context).textTheme.bodySmall),
					],
				),
			),
		);
	}
}

class _EmployeeCard extends StatelessWidget {
	const _EmployeeCard({required this.employee});

	final Employee employee;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Card(
			child: ListTile(
				contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
				leading: CircleAvatar(
					backgroundColor: colorScheme.primaryContainer,
					child: Text(
						employee.name[0],
						style: TextStyle(color: colorScheme.onPrimaryContainer),
					),
				),
				title: Text(employee.name),
				subtitle: Text('${employee.role} • ${employee.department}'),
				trailing: Container(
					padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
					decoration: BoxDecoration(
						color: employee.status == 'Active'
								? Colors.green.withValues(alpha: 0.12)
								: employee.status == 'Inactive'
										? Colors.red.withValues(alpha: 0.12)
										: Colors.orange.withValues(alpha: 0.14),
						borderRadius: BorderRadius.circular(20),
					),
					child: Text(
						employee.status,
						style: TextStyle(
							color: employee.status == 'Active'
									? Colors.green.shade700
									: employee.status == 'Inactive'
											? Colors.red.shade700
											: Colors.orange.shade700,
							fontWeight: FontWeight.w600,
							fontSize: 12,
						),
					),
				),
			),
		);
	}
}

class Employee {
	const Employee({
		required this.name,
		required this.role,
		required this.department,
		required this.status,
	});

	final String name;
	final String role;
	final String department;
	final String status;

	factory Employee.fromJson(Map<String, dynamic> json) {
		return Employee(
			name: json['fullName'] ?? 'Unknown',
			role: json['role'] ?? 'Unknown',
			department: json['department'] ?? 'Unknown',
			status: json['status'] ?? 'Active',
		);
	}
}

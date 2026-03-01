import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class EmployeesScreenAdmin extends StatefulWidget {
  const EmployeesScreenAdmin({super.key});

  @override
  State<EmployeesScreenAdmin> createState() => _EmployeesScreenAdminState();
}

class _EmployeesScreenAdminState extends State<EmployeesScreenAdmin> {
  late final TextEditingController _searchController;
  String _searchText = '';
  String _departmentFilter = 'All';
  bool _isLoading = true;
  List<AdminEmployee> _employees = [];

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
          _employees = data
              .map((json) => AdminEmployee.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load employees'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not connect to the server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminEmployee> get _filteredEmployees {
    Iterable<AdminEmployee> result = _employees;

    if (_searchText.trim().isNotEmpty) {
      final query = _searchText.trim().toLowerCase();
      result = result.where(
        (employee) =>
            employee.name.toLowerCase().contains(query) ||
            employee.role.toLowerCase().contains(query) ||
            employee.department.toLowerCase().contains(query) ||
            employee.email.toLowerCase().contains(query),
      );
    }

    if (_departmentFilter != 'All') {
      result = result.where(
        (employee) => employee.department == _departmentFilter,
      );
    }

    return result.toList();
  }

  List<String> get _departments {
    final values =
        _employees.map((employee) => employee.department).toSet().toList()
          ..sort();
    return ['All', ...values];
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = _filteredEmployees;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Company Directory',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage and view all employee details across departments.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchText = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by name, role, email...',
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
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _departments
                      .map(
                        (department) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
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
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredEmployees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.group_off_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No employees found.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: _buildGroupedEmployeeList(
                    filteredEmployees,
                    context,
                  ),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedEmployeeList(
    List<AdminEmployee> employees,
    BuildContext context,
  ) {
    final Map<String, List<AdminEmployee>> grouped = {};
    for (var emp in employees) {
      if (!grouped.containsKey(emp.department)) {
        grouped[emp.department] = [];
      }
      grouped[emp.department]!.add(emp);
    }

    final sortedDepartments = grouped.keys.toList()..sort();
    final List<Widget> widgets = [];

    for (var dept in sortedDepartments) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(
                Icons.domain,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '$dept Department',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );

      for (var emp in grouped[dept]!) {
        widgets.add(_AdminEmployeeTile(employee: emp));
      }
    }

    return widgets;
  }
}

class _AdminEmployeeTile extends StatelessWidget {
  const _AdminEmployeeTile({required this.employee});

  final AdminEmployee employee;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${employee.role} | ${employee.department}'),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(icon: Icons.email_outlined, text: employee.email),
                const SizedBox(height: 12),
                _DetailRow(icon: Icons.phone_outlined, text: employee.phone),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Details'),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.block, size: 18),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      label: const Text('Suspend'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class AdminEmployee {
  const AdminEmployee({
    required this.name,
    required this.role,
    required this.department,
    required this.status,
    required this.email,
    required this.phone,
  });

  final String name;
  final String role;
  final String department;
  final String status;
  final String email;
  final String phone;

  factory AdminEmployee.fromJson(Map<String, dynamic> json) {
    return AdminEmployee(
      name: json['fullName'] ?? 'Unknown',
      role: json['role'] ?? 'Unknown',
      department: json['department'] ?? 'Unknown',
      status: json['status'] ?? 'Active',
      email: json['email'] ?? 'No email provided',
      phone: json['phoneNumber'] ?? 'No phone provided',
    );
  }
}

import 'package:flutter/material.dart';

class EmployeesScreen extends StatelessWidget {
	const EmployeesScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Padding(
					padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
					child: TextField(
						decoration: InputDecoration(
							hintText: 'Search employees...',
							prefixIcon: const Icon(Icons.search),
							filled: true,
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide.none,
							),
						),
					),
				),
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
					child: Row(
						children: const [
							Expanded(
								child: _MiniStatCard(
									title: 'Total',
									value: '128',
									icon: Icons.groups_2_outlined,
								),
							),
							SizedBox(width: 10),
							Expanded(
								child: _MiniStatCard(
									title: 'Active',
									value: '117',
									icon: Icons.verified_user_outlined,
								),
							),
						],
					),
				),
				Expanded(
					child: ListView.separated(
						padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
						itemCount: _employees.length,
						separatorBuilder: (_, __) => const SizedBox(height: 10),
						itemBuilder: (context, index) {
							final employee = _employees[index];
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
						color: employee.isActive
								? Colors.green.withValues(alpha: 0.12)
								: Colors.orange.withValues(alpha: 0.14),
						borderRadius: BorderRadius.circular(20),
					),
					child: Text(
						employee.isActive ? 'Active' : 'On Leave',
						style: TextStyle(
							color: employee.isActive ? Colors.green.shade700 : Colors.orange.shade700,
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
		required this.isActive,
	});

	final String name;
	final String role;
	final String department;
	final bool isActive;
}

const List<Employee> _employees = [
	Employee(
		name: 'Aarav Patel',
		role: 'HR Manager',
		department: 'Human Resources',
		isActive: true,
	),
	Employee(
		name: 'Diya Sharma',
		role: 'Software Engineer',
		department: 'Engineering',
		isActive: true,
	),
	Employee(
		name: 'Rohan Gupta',
		role: 'UI/UX Designer',
		department: 'Design',
		isActive: false,
	),
	Employee(
		name: 'Neha Verma',
		role: 'Finance Analyst',
		department: 'Finance',
		isActive: true,
	),
	Employee(
		name: 'Kabir Khan',
		role: 'Operations Lead',
		department: 'Operations',
		isActive: true,
	),
];

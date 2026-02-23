import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
	const AttendanceScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						'Today\'s Attendance',
						style: Theme.of(context).textTheme.headlineSmall,
					),
					const SizedBox(height: 6),
					Text(
						'Monitor check-ins, late arrivals, and leave status.',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					const SizedBox(height: 16),
					Row(
						children: const [
							Expanded(
								child: _AttendanceStatCard(
									title: 'Present',
									value: '112',
									icon: Icons.check_circle_outline,
								),
							),
							SizedBox(width: 10),
							Expanded(
								child: _AttendanceStatCard(
									title: 'Absent',
									value: '07',
									icon: Icons.cancel_outlined,
								),
							),
							SizedBox(width: 10),
							Expanded(
								child: _AttendanceStatCard(
									title: 'Late',
									value: '09',
									icon: Icons.access_time,
								),
							),
						],
					),
					const SizedBox(height: 18),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(14),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Department Summary',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 10),
									const _DepartmentRow(
										department: 'Engineering',
										present: 42,
										total: 46,
									),
									const SizedBox(height: 8),
									const _DepartmentRow(
										department: 'Human Resources',
										present: 18,
										total: 19,
									),
									const SizedBox(height: 8),
									const _DepartmentRow(
										department: 'Finance',
										present: 15,
										total: 17,
									),
								],
							),
						),
					),
					const SizedBox(height: 18),
					Text(
						'Recent Check-ins',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 10),
					..._recentAttendance.map((entry) => _CheckInTile(entry: entry)),
				],
			),
		);
	}
}

class _AttendanceStatCard extends StatelessWidget {
	const _AttendanceStatCard({
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

class _DepartmentRow extends StatelessWidget {
	const _DepartmentRow({
		required this.department,
		required this.present,
		required this.total,
	});

	final String department;
	final int present;
	final int total;

	@override
	Widget build(BuildContext context) {
		final rate = (present / total) * 100;

		return Row(
			children: [
				Expanded(child: Text(department)),
				Text('$present/$total (${rate.toStringAsFixed(0)}%)'),
			],
		);
	}
}

class _CheckInTile extends StatelessWidget {
	const _CheckInTile({required this.entry});

	final AttendanceEntry entry;

	@override
	Widget build(BuildContext context) {
		final statusColor = entry.status == 'On Time'
				? Colors.green.shade700
				: Colors.orange.shade700;

		return Card(
			margin: const EdgeInsets.only(bottom: 10),
			child: ListTile(
				leading: CircleAvatar(child: Text(entry.name[0])),
				title: Text(entry.name),
				subtitle: Text('${entry.time} • ${entry.department}'),
				trailing: Text(
					entry.status,
					style: TextStyle(
						color: statusColor,
						fontWeight: FontWeight.w600,
					),
				),
			),
		);
	}
}

class AttendanceEntry {
	const AttendanceEntry({
		required this.name,
		required this.time,
		required this.department,
		required this.status,
	});

	final String name;
	final String time;
	final String department;
	final String status;
}

const List<AttendanceEntry> _recentAttendance = [
	AttendanceEntry(
		name: 'Aarav Patel',
		time: '09:02 AM',
		department: 'HR',
		status: 'On Time',
	),
	AttendanceEntry(
		name: 'Diya Sharma',
		time: '09:11 AM',
		department: 'Engineering',
		status: 'Late',
	),
	AttendanceEntry(
		name: 'Neha Verma',
		time: '08:56 AM',
		department: 'Finance',
		status: 'On Time',
	),
	AttendanceEntry(
		name: 'Kabir Khan',
		time: '09:07 AM',
		department: 'Operations',
		status: 'On Time',
	),
];

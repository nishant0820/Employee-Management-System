import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
	const AttendanceScreen({super.key});

	@override
	State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
	String _statusFilter = 'All';

	List<String> get _statusFilters {
		final statuses = _recentAttendance.map((entry) => entry.status).toSet().toList()
			..sort();
		return ['All', ...statuses];
	}

	@override
	Widget build(BuildContext context) {
		final int presentEmployees = _recentAttendance.length;
		final int onLeaveCount = _onLeaveEmployees.length;
		final int totalEmployees = presentEmployees + onLeaveCount;
		final int lateEmployees =
				_recentAttendance.where((entry) => entry.status == 'Late').length;
		final int absentEmployees = onLeaveCount;
		final attendanceRate =
				totalEmployees == 0 ? 0.0 : presentEmployees / totalEmployees;
		final Map<String, int> departmentSummary = {};
		for (final entry in _recentAttendance) {
			departmentSummary.update(
				entry.department,
				(value) => value + 1,
				ifAbsent: () => 1,
			);
		}

		final filteredAttendance = _statusFilter == 'All'
				? _recentAttendance
				: _recentAttendance.where((entry) => entry.status == _statusFilter).toList();

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Card(
						child: Padding(
							padding: const EdgeInsets.all(14),
							child: Row(
								children: [
									const Icon(Icons.calendar_month_outlined),
									const SizedBox(width: 10),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													'Today • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
													style: Theme.of(context).textTheme.titleMedium,
												),
												Text(
													'Active Shift: --',
													style: Theme.of(context).textTheme.bodySmall,
												),
											],
										),
									),
								],
							),
						),
					),
					const SizedBox(height: 14),
					Text(
						'Today\'s Attendance',
						style: Theme.of(context).textTheme.headlineSmall,
					),
					const SizedBox(height: 6),
					Text(
						'Monitor check-ins, late arrivals, and leave status.',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					const SizedBox(height: 14),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(14),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Row(
										children: [
											Expanded(
												child: Text(
													'Overall Attendance Rate',
													style: Theme.of(context).textTheme.titleMedium,
												),
											),
											Text(
												'${(attendanceRate * 100).toStringAsFixed(1)}%',
												style: Theme.of(context).textTheme.titleMedium,
											),
										],
									),
									const SizedBox(height: 10),
									LinearProgressIndicator(value: attendanceRate),
									const SizedBox(height: 8),
									Text(
										'$presentEmployees of $totalEmployees employees checked in',
										style: Theme.of(context).textTheme.bodySmall,
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: _AttendanceStatCard(
									title: 'Present',
									value: '$presentEmployees',
									icon: Icons.check_circle_outline,
								),
							),
							const SizedBox(width: 10),
							Expanded(
								child: _AttendanceStatCard(
									title: 'Absent',
									value: '$absentEmployees',
									icon: Icons.cancel_outlined,
								),
							),
							const SizedBox(width: 10),
							Expanded(
								child: _AttendanceStatCard(
									title: 'Late',
									value: '$lateEmployees',
									icon: Icons.access_time,
								),
							),
						],
					),
					const SizedBox(height: 18),
					Text(
						'Quick Actions',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 10),
					Row(
						children: const [
							Expanded(
								child: _ActionCard(
									icon: Icons.file_download_outlined,
									title: 'Export Report',
									subtitle: 'CSV / PDF',
								),
							),
							SizedBox(width: 10),
							Expanded(
								child: _ActionCard(
									icon: Icons.notifications_active_outlined,
									title: 'Late Alerts',
									subtitle: 'Notify managers',
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
									if (departmentSummary.isEmpty)
										Text(
											'No department attendance available.',
											style: Theme.of(context).textTheme.bodySmall,
										)
									else
										...departmentSummary.entries.map(
											(entry) => Padding(
												padding: const EdgeInsets.only(bottom: 8),
												child: _DepartmentRow(
													department: entry.key,
													present: entry.value,
													total: entry.value,
												),
											),
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
					const SizedBox(height: 8),
					Wrap(
						spacing: 8,
						children: _statusFilters
								.map(
									(label) => ChoiceChip(
										label: Text(label),
										selected: _statusFilter == label,
										onSelected: (_) {
											setState(() => _statusFilter = label);
										},
									),
								)
								.toList(),
					),
					const SizedBox(height: 10),
					if (filteredAttendance.isEmpty)
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 8),
							child: Text(
								'No entries found for $_statusFilter.',
								style: Theme.of(context).textTheme.bodyMedium,
							),
						)
					else
						...filteredAttendance.map((entry) => _CheckInTile(entry: entry)),
					const SizedBox(height: 8),
					Text(
						'Team on Leave',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 10),
					if (_onLeaveEmployees.isEmpty)
						Text(
							'No employees are currently on leave.',
							style: Theme.of(context).textTheme.bodyMedium,
						)
					else
						..._onLeaveEmployees.map((entry) => _LeaveTile(entry: entry)),
				],
			),
		);
	}
}

class _ActionCard extends StatelessWidget {
	const _ActionCard({
		required this.icon,
		required this.title,
		required this.subtitle,
	});

	final IconData icon;
	final String title;
	final String subtitle;

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
						Text(title, style: Theme.of(context).textTheme.titleSmall),
						Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
					],
				),
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

class LeaveEntry {
	const LeaveEntry({
		required this.name,
		required this.type,
		required this.days,
	});

	final String name;
	final String type;
	final String days;
}

class _LeaveTile extends StatelessWidget {
	const _LeaveTile({required this.entry});

	final LeaveEntry entry;

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.only(bottom: 10),
			child: ListTile(
				leading: CircleAvatar(child: Text(entry.name[0])),
				title: Text(entry.name),
				subtitle: Text(entry.days),
				trailing: Text(entry.type),
			),
		);
	}
}

const List<AttendanceEntry> _recentAttendance = [];

const List<LeaveEntry> _onLeaveEmployees = [];

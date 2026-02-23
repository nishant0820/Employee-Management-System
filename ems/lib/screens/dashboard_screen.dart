import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
	const DashboardScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						'Welcome back, Admin',
						style: Theme.of(context).textTheme.headlineSmall,
					),
					const SizedBox(height: 6),
					Text(
						'Here is your EMS portal overview for today.',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					const SizedBox(height: 20),
					GridView.count(
						crossAxisCount: 2,
						shrinkWrap: true,
						physics: const NeverScrollableScrollPhysics(),
						mainAxisSpacing: 12,
						crossAxisSpacing: 12,
						childAspectRatio: 1.35,
						children: const [
							_StatCard(
								title: 'Total Employees',
								value: '128',
								icon: Icons.groups_2_outlined,
							),
							_StatCard(
								title: 'Present Today',
								value: '112',
								icon: Icons.check_circle_outline,
							),
							_StatCard(
								title: 'On Leave',
								value: '09',
								icon: Icons.beach_access_outlined,
							),
							_StatCard(
								title: 'Pending Requests',
								value: '06',
								icon: Icons.pending_actions_outlined,
							),
						],
					),
					const SizedBox(height: 20),
					Text(
						'Quick Actions',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 12),
					Wrap(
						spacing: 10,
						runSpacing: 10,
						children: const [
							_ActionChip(label: 'Add Employee', icon: Icons.person_add_alt_1),
							_ActionChip(label: 'Mark Attendance', icon: Icons.fact_check),
							_ActionChip(label: 'Approve Leave', icon: Icons.how_to_reg),
							_ActionChip(label: 'Generate Report', icon: Icons.assessment_outlined),
						],
					),
					const SizedBox(height: 20),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Today\'s Summary',
										style: Theme.of(context).textTheme.titleMedium,
									),
									const SizedBox(height: 12),
									const _SummaryRow(label: 'Check-ins', value: '109'),
									const SizedBox(height: 8),
									const _SummaryRow(label: 'Late Arrivals', value: '7'),
									const SizedBox(height: 8),
									const _SummaryRow(label: 'Early Leaves', value: '3'),
								],
							),
						),
					),
				],
			),
		);
	}
}

class _StatCard extends StatelessWidget {
	const _StatCard({
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
				padding: const EdgeInsets.all(14),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Icon(icon, color: colorScheme.primary),
						const Spacer(),
						Text(value, style: Theme.of(context).textTheme.headlineSmall),
						const SizedBox(height: 4),
						Text(title, style: Theme.of(context).textTheme.bodySmall),
					],
				),
			),
		);
	}
}

class _ActionChip extends StatelessWidget {
	const _ActionChip({required this.label, required this.icon});

	final String label;
	final IconData icon;

	@override
	Widget build(BuildContext context) {
		return ActionChip(
			avatar: Icon(icon, size: 18),
			label: Text(label),
			onPressed: () {},
		);
	}
}

class _SummaryRow extends StatelessWidget {
	const _SummaryRow({required this.label, required this.value});

	final String label;
	final String value;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Expanded(child: Text(label)),
				Text(
					value,
					style: Theme.of(context).textTheme.titleMedium,
				),
			],
		);
	}
}

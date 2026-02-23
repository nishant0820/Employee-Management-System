import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
	const NotificationsScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: [
					Padding(
						padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
						child: Row(
							children: [
								Expanded(
									child: Text(
										'Recent Alerts',
										style: Theme.of(context).textTheme.titleLarge,
									),
								),
								TextButton(
									onPressed: () {},
									child: const Text('Mark all read'),
								),
							],
						),
					),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: Row(
							children: const [
								_FilterChip(label: 'All', selected: true),
								SizedBox(width: 8),
								_FilterChip(label: 'Leaves', selected: false),
								SizedBox(width: 8),
								_FilterChip(label: 'Attendance', selected: false),
							],
						),
					),
					const SizedBox(height: 8),
					Expanded(
						child: ListView.separated(
							padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
							itemCount: _notifications.length,
							separatorBuilder: (_, __) => const SizedBox(height: 10),
							itemBuilder: (context, index) {
								final item = _notifications[index];
								return _NotificationCard(item: item);
							},
						),
					),
				],
			),
		);
	}
}

class _NotificationCard extends StatelessWidget {
	const _NotificationCard({required this.item});

	final NotificationItem item;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Card(
			child: ListTile(
				contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
				leading: Stack(
					clipBehavior: Clip.none,
					children: [
						CircleAvatar(
							backgroundColor: colorScheme.primaryContainer,
							child: Icon(item.icon, color: colorScheme.onPrimaryContainer),
						),
						if (item.isUnread)
							Positioned(
								top: -2,
								right: -2,
								child: Container(
									width: 10,
									height: 10,
									decoration: const BoxDecoration(
										color: Colors.red,
										shape: BoxShape.circle,
									),
								),
							),
					],
				),
				title: Text(item.title),
				subtitle: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const SizedBox(height: 4),
						Text(item.message),
						const SizedBox(height: 6),
						Text(
							item.time,
							style: Theme.of(context).textTheme.bodySmall,
						),
					],
				),
				trailing: const Icon(Icons.chevron_right),
				onTap: () {},
			),
		);
	}
}

class _FilterChip extends StatelessWidget {
	const _FilterChip({required this.label, required this.selected});

	final String label;
	final bool selected;

	@override
	Widget build(BuildContext context) {
		return Chip(
			label: Text(label),
			backgroundColor:
					selected ? Theme.of(context).colorScheme.primaryContainer : null,
			side: BorderSide(
				color: selected
						? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
						: Colors.transparent,
			),
		);
	}
}

class NotificationItem {
	const NotificationItem({
		required this.title,
		required this.message,
		required this.time,
		required this.icon,
		required this.isUnread,
	});

	final String title;
	final String message;
	final String time;
	final IconData icon;
	final bool isUnread;
}

const List<NotificationItem> _notifications = [
	NotificationItem(
		title: 'Leave Request Pending',
		message: 'Neha Verma submitted a leave request for Feb 25.',
		time: '10 min ago',
		icon: Icons.beach_access_outlined,
		isUnread: true,
	),
	NotificationItem(
		title: 'Late Arrival Alert',
		message: 'Diya Sharma checked in late at 09:11 AM.',
		time: '35 min ago',
		icon: Icons.access_time,
		isUnread: true,
	),
	NotificationItem(
		title: 'New Employee Added',
		message: 'A new employee profile was created in Engineering.',
		time: '2 hours ago',
		icon: Icons.person_add_alt_1,
		isUnread: false,
	),
	NotificationItem(
		title: 'Attendance Report Ready',
		message: 'Today\'s attendance summary report is now available.',
		time: '3 hours ago',
		icon: Icons.assessment_outlined,
		isUnread: false,
	),
];

import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
	const NotificationsScreen({super.key});

	@override
	State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
	String _selectedFilter = 'All';

	List<String> get _availableFilters {
		final categories = _notifications.map((item) => item.category).toSet().toList()
			..sort();
		return ['All', ...categories];
	}

	List<NotificationItem> get _filteredNotifications {
		if (_selectedFilter == 'All') return _notifications;
		return _notifications.where((item) => item.category == _selectedFilter).toList();
	}

	int get _unreadCount => _notifications.where((item) => item.isUnread).length;

	@override
	Widget build(BuildContext context) {
		final filteredNotifications = _filteredNotifications;
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			appBar: AppBar(
				title: const Text('Notifications'),
				actions: [
					if (_unreadCount > 0)
						TextButton.icon(
							onPressed: () {
								// Mark all as read
							},
							icon: const Icon(Icons.done_all, size: 18),
							label: const Text('Mark all read'),
						),
				],
			),
			body: Column(
				children: [
					if (_unreadCount > 0)
						Container(
							width: double.infinity,
							margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
							padding: const EdgeInsets.all(14),
							decoration: BoxDecoration(
								color: colorScheme.primaryContainer.withValues(alpha: 0.3),
								borderRadius: BorderRadius.circular(12),
								border: Border.all(
									color: colorScheme.primary.withValues(alpha: 0.2),
								),
							),
							child: Row(
								children: [
									Icon(Icons.notifications_active, color: colorScheme.primary),
									const SizedBox(width: 12),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													'You have $_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}',
													style: Theme.of(context).textTheme.titleSmall?.copyWith(
														fontWeight: FontWeight.w600,
													),
												),
												Text(
													'Stay updated with latest alerts',
													style: Theme.of(context).textTheme.bodySmall,
												),
											],
										),
									),
								],
							),
						),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
						child: Row(
							children: [
								Text(
									'Filter by:',
									style: Theme.of(context).textTheme.bodyMedium?.copyWith(
										fontWeight: FontWeight.w500,
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: SingleChildScrollView(
										scrollDirection: Axis.horizontal,
										child: Row(
											children: _availableFilters
													.map(
														(label) => Padding(
															padding: const EdgeInsets.only(right: 8),
															child: ChoiceChip(
																label: Text(label),
																selected: _selectedFilter == label,
																onSelected: (_) {
																	setState(() => _selectedFilter = label);
																},
															),
														),
													)
													.toList(),
										),
									),
								),
							],
						),
					),
					const Divider(height: 1),
					Expanded(
						child: filteredNotifications.isEmpty
								? Center(
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Icon(
													Icons.notifications_none_outlined,
													size: 64,
													color: colorScheme.outline,
												),
												const SizedBox(height: 16),
												Text(
													'No notifications',
													style: Theme.of(context).textTheme.titleMedium,
												),
												const SizedBox(height: 4),
												Text(
													'You\'re all caught up!',
													style: Theme.of(context).textTheme.bodyMedium?.copyWith(
														color: colorScheme.outline,
													),
												),
											],
										),
									)
								: ListView.separated(
										padding: const EdgeInsets.all(16),
										itemCount: filteredNotifications.length,
										separatorBuilder: (_, __) => const SizedBox(height: 10),
										itemBuilder: (context, index) {
											final item = filteredNotifications[index];
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
			elevation: item.isUnread ? 2 : 1,
			color: item.isUnread 
				? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
				: null,
			child: InkWell(
				onTap: () {},
				borderRadius: BorderRadius.circular(12),
				child: Padding(
					padding: const EdgeInsets.all(14),
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Stack(
								clipBehavior: Clip.none,
								children: [
									Container(
										padding: const EdgeInsets.all(10),
										decoration: BoxDecoration(
											color: colorScheme.primaryContainer,
											shape: BoxShape.circle,
										),
										child: Icon(
											item.icon, 
											color: colorScheme.onPrimaryContainer,
											size: 22,
										),
									),
									if (item.isUnread)
										Positioned(
											top: -2,
											right: -2,
											child: Container(
												width: 12,
												height: 12,
												decoration: BoxDecoration(
													color: colorScheme.error,
													shape: BoxShape.circle,
													border: Border.all(
														color: colorScheme.surface,
														width: 2,
													),
												),
											),
										),
									],
								),
								const SizedBox(width: 14),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Row(
												children: [
													Expanded(
														child: Text(
															item.title,
															style: Theme.of(context).textTheme.titleSmall?.copyWith(
																fontWeight: item.isUnread ? FontWeight.w600 : FontWeight.w500,
															),
														),
													),
													Text(
														item.time,
														style: Theme.of(context).textTheme.bodySmall?.copyWith(
															color: colorScheme.outline,
														),
													),
												],
											),
											const SizedBox(height: 6),
											Text(
												item.message,
												style: Theme.of(context).textTheme.bodyMedium,
											),
											const SizedBox(height: 8),
											Container(
												padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
													borderRadius: BorderRadius.circular(6),
												),
												child: Text(
													item.category,
													style: Theme.of(context).textTheme.bodySmall?.copyWith(
														fontSize: 11,
														fontWeight: FontWeight.w500,
													),
												),
											),
									],
								),
							),
						],
					),
				),
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
		required this.category,
	});

	final String title;
	final String message;
	final String time;
	final IconData icon;
	final bool isUnread;
	final String category;
}

const List<NotificationItem> _notifications = [];

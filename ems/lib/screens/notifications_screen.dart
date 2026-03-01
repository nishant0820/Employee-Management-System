import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:ems/screens/notification_sisible_screen.dart';

class NotificationsScreen extends StatefulWidget {
	const NotificationsScreen({super.key});

	@override
	State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
	String _selectedFilter = 'All';
	List<NotificationItem> _notifications = [];
	Timer? _timer;

	@override
	void initState() {
		super.initState();
		_loadNotifications();
		_timer = Timer.periodic(const Duration(minutes: 1), (timer) {
			if (mounted) setState(() {});
		});
	}

	@override
	void dispose() {
		_timer?.cancel();
		super.dispose();
	}

	Future<void> _loadNotifications() async {
		final prefs = await SharedPreferences.getInstance();
		final List<String> saved = prefs.getStringList('notifications_list') ?? [];
		if (mounted) {
			setState(() {
				_notifications = saved.map((str) {
					final Map<String, dynamic> data = json.decode(str);
					return NotificationItem(
						title: data['title'] ?? '',
						message: data['message'] ?? '',
						time: data['timestamp'] ?? data['time'] ?? 'Just now',
						icon: data['icon'] == 'login' ? Icons.login : Icons.notifications,
						isUnread: data['isUnread'] ?? false,
						category: data['category'] ?? 'System',
					);
				}).toList();
			});
		}
	}

	List<String> get _availableFilters {
		final categories = _notifications.map((item) => item.category).toSet().toList()
			..sort();
		return ['All', ...categories];
	}

	List<NotificationItem> get _filteredNotifications {
		if (_selectedFilter == 'All') return _notifications;
		return _notifications.where((item) => item.category == _selectedFilter).toList();
	}

	Future<void> _handleNotificationTap(NotificationItem item) async {
		final int index = _notifications.indexOf(item);
		if (index != -1 && item.isUnread) {
			setState(() {
				item.isUnread = false;
			});
			
			final prefs = await SharedPreferences.getInstance();
			final List<String> saved = prefs.getStringList('notifications_list') ?? [];
			if (index < saved.length) {
				final data = json.decode(saved[index]);
				data['isUnread'] = false;
				saved[index] = json.encode(data);
				await prefs.setStringList('notifications_list', saved);
			}
		}

		if (!mounted) return;
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (_) => NotificationVisibleScreen(item: item),
			),
		);
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
							onPressed: () async {
								final prefs = await SharedPreferences.getInstance();
								final List<String> saved = prefs.getStringList('notifications_list') ?? [];
								final updated = saved.map((str) {
									final data = json.decode(str);
									data['isUnread'] = false;
									return json.encode(data);
								}).toList();
								await prefs.setStringList('notifications_list', updated);
								
								setState(() {
									for (var item in _notifications) {
										item.isUnread = false;
									}
								});
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
											return _NotificationCard(
												item: item,
												onTap: () => _handleNotificationTap(item),
											);
										},
									),
					),
				],
			),
		);
	}
}

String formatTimeAgo(String timestampStr) {
	if (timestampStr.isEmpty) return 'Just now';
	try {
		final DateTime time = DateTime.parse(timestampStr);
		final Duration diff = DateTime.now().difference(time);
		if (diff.inSeconds < 60) return 'Just now';
		if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
		if (diff.inHours < 24) return '${diff.inHours} hr ago';
		if (diff.inDays == 1) return '1 day ago';
		if (diff.inDays < 7) return '${diff.inDays} days ago';
		return '${time.day}/${time.month}/${time.year}';
	} catch (e) {
		return timestampStr; // fallback for pre-existing 'Just now'
	}
}

class _NotificationCard extends StatelessWidget {
	const _NotificationCard({required this.item, required this.onTap});

	final NotificationItem item;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Card(
			elevation: item.isUnread ? 2 : 1,
			color: item.isUnread 
				? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
				: null,
			child: InkWell(
				onTap: onTap,
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
														formatTimeAgo(item.time),
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
	NotificationItem({
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
	bool isUnread;
	final String category;
}

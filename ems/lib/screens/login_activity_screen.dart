import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class LoginActivityScreen extends StatefulWidget {
	const LoginActivityScreen({super.key});

	@override
	State<LoginActivityScreen> createState() => _LoginActivityScreenState();
}

class _LoginActivityScreenState extends State<LoginActivityScreen> {
	List<dynamic> _activityList = [];
	Timer? _timer;

	@override
	void initState() {
		super.initState();
		_loadActivity();
		_timer = Timer.periodic(const Duration(minutes: 1), (timer) {
			if (mounted) setState(() {});
		});
	}

	@override
	void dispose() {
		_timer?.cancel();
		super.dispose();
	}

	Future<void> _loadActivity() async {
		final prefs = await SharedPreferences.getInstance();
		final List<String> saved = prefs.getStringList('login_activity_list') ?? [];
		if (mounted) {
			setState(() {
				_activityList = saved.map((str) => json.decode(str)).toList();
			});
		}
	}

	String _formatTimeAgo(String timestampStr) {
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
			return timestampStr; 
		}
	}

	String _formatTimeDetailed(String timestampStr) {
		if (timestampStr.isEmpty) return '';
		try {
			final DateTime time = DateTime.parse(timestampStr);
			final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
			final minute = time.minute.toString().padLeft(2, '0');
			final period = time.hour >= 12 ? 'PM' : 'AM';
			return '${time.day}/${time.month}/${time.year} at $hour:$minute $period';
		} catch (e) {
			return timestampStr; 
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Login Activity'),
			),
			body: _activityList.isEmpty 
				? const Center(child: Text('No recent login activity.'))
				: ListView.separated(
					padding: const EdgeInsets.all(16),
					itemCount: _activityList.length,
					separatorBuilder: (_, __) => const SizedBox(height: 10),
					itemBuilder: (context, index) {
						final activity = _activityList[index];
						final timestamp = activity['timestamp'] ?? '';
						final device = activity['device'] ?? 'Unknown device';
						final colorScheme = Theme.of(context).colorScheme;

						return Card(
							elevation: index == 0 ? 2 : 1,
							child: ListTile(
								leading: CircleAvatar(
									backgroundColor: index == 0 
										? Colors.green.withValues(alpha: 0.15)
										: colorScheme.surfaceContainerHighest,
									child: Icon(
										Icons.login, 
										color: index == 0 ? Colors.green.shade700 : colorScheme.onSurfaceVariant,
									),
								),
								title: Text(
									index == 0 ? 'Current Session' : 'Successful Login',
									style: TextStyle(
										fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
									),
								),
								subtitle: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const SizedBox(height: 4),
										Text('Device: $device'),
										Text(_formatTimeDetailed(timestamp)),
									],
								),
								trailing: Text(
									_formatTimeAgo(timestamp),
									style: TextStyle(
										color: colorScheme.outline,
										fontSize: 12,
									),
								),
								isThreeLine: true,
							),
						);
					},
				),
		);
	}
}

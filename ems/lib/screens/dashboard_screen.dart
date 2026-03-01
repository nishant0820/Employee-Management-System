import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ems/screens/add_employees_screen.dart';
import 'package:ems/screens/approve_leave_screen.dart';
import 'package:ems/screens/generate_report_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
	const DashboardScreen({super.key});

	@override
	State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
	String _selectedPeriod = 'Today';
	DateTime _currentTime = DateTime.now();
	Timer? _timer;

	int _totalEmployees = 0;
	int _activeEmployees = 0;
	int _onLeaveEmployees = 0;
	bool _isLoading = true;
	String _userName = 'Admin';
	bool _isNewUser = false;

	@override
	void initState() {
		super.initState();
		_loadUserData();
		_fetchDashboardData();
		// Update time every second
		_timer = Timer.periodic(const Duration(seconds: 1), (timer) {
			setState(() {
				_currentTime = DateTime.now();
			});
		});
	}

	Future<void> _loadUserData() async {
		final prefs = await SharedPreferences.getInstance();
		final fullName = prefs.getString('full_name');
		final isNewUser = prefs.getBool('is_new_user') ?? false;
		
		if (fullName != null && fullName.isNotEmpty) {
			if (mounted) {
				setState(() {
					_userName = fullName;
					_isNewUser = isNewUser;
				});
			}
		}
	}

	Future<void> _fetchDashboardData() async {
		try {
			String baseUrl = 'https://employee-management-system-tefv.onrender.com/';
			if (!kIsWeb) {
				if (Platform.isAndroid) {
					baseUrl = 'https://employee-management-system-tefv.onrender.com/';
				}
			}

			final response = await http.get(Uri.parse('$baseUrl/api/employees'));

			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				
				int active = 0;
				int onLeave = 0;

				for (var jsonData in data) {
					String status = jsonData['status'] ?? 'Active';
					if (status == 'Active') {
						active++;
					} else if (status == 'On Leave') {
						onLeave++;
					}
				}

				if (mounted) {
					setState(() {
						_totalEmployees = data.length;
						_activeEmployees = active;
						_onLeaveEmployees = onLeave;
						_isLoading = false;
					});
				}
			} else {
				if (mounted) setState(() => _isLoading = false);
			}
		} catch (error) {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	@override
	void dispose() {
		_timer?.cancel();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final totalEmployees = _totalEmployees;
		final presentToday = _activeEmployees; // Simulated Attendance mapped to Active
		final onLeaveToday = _onLeaveEmployees;
		const pendingRequests = 0;
		final attendanceRate =
				totalEmployees == 0 ? 0.0 : presentToday / totalEmployees;

		final now = _currentTime;
		// Format time with hours, minutes, and seconds
		final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
		final minute = now.minute.toString().padLeft(2, '0');
		final second = now.second.toString().padLeft(2, '0');
		final period = now.hour >= 12 ? 'PM' : 'AM';
		final formattedTime = '$hour:$minute:$second $period';
		
		// Format real-time date with day name
		const weekdays = [
			'Monday',
			'Tuesday',
			'Wednesday',
			'Thursday',
			'Friday',
			'Saturday',
			'Sunday',
		];
		const months = [
			'Jan',
			'Feb',
			'Mar',
			'Apr',
			'May',
			'Jun',
			'Jul',
			'Aug',
			'Sep',
			'Oct',
			'Nov',
			'Dec',
		];
		final formattedDate =
				'${weekdays[now.weekday - 1]}  •  ${now.day} ${months[now.month - 1]} ${now.year}';

		if (_isLoading) {
			return const Center(child: CircularProgressIndicator());
		}

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Card(
						child: Padding(
							padding: const EdgeInsets.all(14),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Row(
										children: [
											const Icon(Icons.calendar_today_outlined),
											const SizedBox(width: 10),
											Expanded(
												child: Text(
													formattedDate,
													style: Theme.of(context).textTheme.titleMedium,
												),
											),
											Text(
												formattedTime,
												style: Theme.of(context).textTheme.titleSmall,
											),
										],
									),
									const SizedBox(height: 6),
									Text(
										'${_selectedPeriod} overview',
										style: Theme.of(context).textTheme.bodySmall,
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Text(
						_isNewUser ? 'Welcome, $_userName' : 'Welcome Back, $_userName',
						style: Theme.of(context).textTheme.headlineSmall,
					),
					const SizedBox(height: 6),
					Text(
						'Here is your EMS portal overview for today.',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					const SizedBox(height: 16),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Row(
										children: [
											Expanded(
												child: Text(
													'Attendance Rate',
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
										'$presentToday of $totalEmployees employees are present',
										style: Theme.of(context).textTheme.bodySmall,
									),
								],
							),
						),
					),
					const SizedBox(height: 20),
					GridView.count(
						crossAxisCount: 2,
						shrinkWrap: true,
						physics: const NeverScrollableScrollPhysics(),
						mainAxisSpacing: 12,
						crossAxisSpacing: 12,
						childAspectRatio: 1.35,
						children: [
							_StatCard(
								title: 'Total Employees',
								value: '$totalEmployees',
								icon: Icons.groups_2_outlined,
							),
							_StatCard(
								title: 'Present Today',
								value: '$presentToday',
								icon: Icons.check_circle_outline,
							),
							_StatCard(
								title: 'On Leave',
								value: '$onLeaveToday',
								icon: Icons.beach_access_outlined,
							),
							_StatCard(
								title: 'Pending Requests',
								value: '$pendingRequests',
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
						children: [
							_ActionChip(
								label: 'Add Employee',
								icon: Icons.person_add_alt_1,
								onPressed: () {
									Navigator.of(context).push(
										MaterialPageRoute(
											builder: (_) => const AddEmployeesScreen(),
										),
									);
								},
							),
							_ActionChip(
								label: 'Approve Leave',
								icon: Icons.how_to_reg,
								onPressed: () {
									Navigator.of(context).push(
										MaterialPageRoute(
											builder: (_) => const ApproveLeaveScreen(),
										),
									);
								},
							),
							_ActionChip(
								label: 'Generate Report',
								icon: Icons.assessment_outlined,
								onPressed: () {
									Navigator.of(context).push(
										MaterialPageRoute(
											builder: (_) => const GenerateReportScreen(),
										),
									);
								},
							),
						],
					),
					const SizedBox(height: 20),
					Text(
						'Announcements',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 10),
					..._announcements.map((item) => _AnnouncementTile(item: item)),
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
									_SummaryRow(label: 'Check-ins', value: '$presentToday'),
									const SizedBox(height: 8),
									const _SummaryRow(label: 'Late Arrivals', value: '0'),
									const SizedBox(height: 8),
									const _SummaryRow(label: 'Early Leaves', value: '0'),
								],
							),
						),
					),
					const SizedBox(height: 18),
					Text(
						'Upcoming',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 10),
					..._upcomingItems.map((item) => _UpcomingTile(item: item)),
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
	const _ActionChip({required this.label, required this.icon, this.onPressed});

	final String label;
	final IconData icon;
	final VoidCallback? onPressed;

	@override
	Widget build(BuildContext context) {
		return ActionChip(
			avatar: Icon(icon, size: 18),
			label: Text(label),
			onPressed: onPressed ?? () {},
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

class AnnouncementItem {
	const AnnouncementItem({
		required this.title,
		required this.description,
		required this.time,
	});

	final String title;
	final String description;
	final String time;
}

class _AnnouncementTile extends StatelessWidget {
	const _AnnouncementTile({required this.item});

	final AnnouncementItem item;

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.only(bottom: 10),
			child: ListTile(
				leading: const Icon(Icons.campaign_outlined),
				title: Text(item.title),
				subtitle: Text('${item.description}\n${item.time}'),
				isThreeLine: true,
			),
		);
	}
}

class UpcomingItem {
	const UpcomingItem({
		required this.title,
		required this.meta,
		required this.icon,
	});

	final String title;
	final String meta;
	final IconData icon;
}

class _UpcomingTile extends StatelessWidget {
	const _UpcomingTile({required this.item});

	final UpcomingItem item;

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.only(bottom: 10),
			child: ListTile(
				leading: Icon(item.icon),
				title: Text(item.title),
				subtitle: Text(item.meta),
				trailing: const Icon(Icons.chevron_right),
			),
		);
	}
}

const List<AnnouncementItem> _announcements = [];

const List<UpcomingItem> _upcomingItems = [];

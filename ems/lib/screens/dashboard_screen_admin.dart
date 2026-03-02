import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ems/screens/add_employees_admin_screen.dart';
import 'package:ems/screens/approve_leave_screen.dart';
import 'package:ems/screens/generate_report_screen.dart';
import 'package:ems/screens/send_announcement_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreenAdmin extends StatefulWidget {
  const DashboardScreenAdmin({super.key});

  @override
  State<DashboardScreenAdmin> createState() => _DashboardScreenAdminState();
}

class _DashboardScreenAdminState extends State<DashboardScreenAdmin> {
  String _selectedPeriod = 'Today';
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  int _totalEmployees = 0;
  int _activeEmployees = 0;
  int _onLeaveEmployees = 0;
  bool _isLoading = true;
  String _adminName = 'Super Admin';
  bool _isNewUser = false;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _fetchDashboardData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('full_name');
    final isNewUser = prefs.getBool('is_new_user') ?? false;

    if (fullName != null && fullName.isNotEmpty) {
      if (mounted) {
        setState(() {
          _adminName = fullName;
          _isNewUser = isNewUser;
        });
      }
    }
  }

  Future<void> _fetchDashboardData() async {
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = _currentTime;
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime = '$hour:$minute:$second $period';

    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final formattedDate = '${weekdays[now.weekday - 1]}  •  ${now.day} ${months[now.month - 1]} ${now.year}';

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
                      const Icon(Icons.shield_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Administrative Console',
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
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isNewUser ? 'Welcome, $_adminName' : 'Welcome Back, $_adminName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Master Dashboard configuration active.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          
          Text(
            'Live Workforce Data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
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
                          'Company Attendance Rate',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${(_totalEmployees == 0 ? 0 : (_activeEmployees / _totalEmployees) * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _totalEmployees == 0 ? 0.0 : _activeEmployees / _totalEmployees,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_activeEmployees of $_totalEmployees employees are present',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.beach_access_outlined, size: 16, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        '$_onLeaveEmployees employees currently on leave',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Core Authority Operations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _ControlListTile(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Recruit / Add Employee',
                  subtitle: 'Register robust personnel, HR or Staff',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddEmployeesAdminScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _ControlListTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Leave Management',
                  subtitle: 'Approve or reject leave requests',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ApproveLeaveScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _ControlListTile(
                  icon: Icons.campaign_outlined,
                  title: 'Global Announcements',
                  subtitle: 'Broadcast company-wide alerts',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SendAnnouncementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _ControlListTile(
                  icon: Icons.assessment_outlined,
                  title: 'Company Reporting',
                  subtitle: 'Generate full analytical overviews',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GenerateReportScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _ControlListTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'System Preferences',
                  subtitle: 'Modify base configurations',
                  onTap: () {
                    // Placeholder for future features
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Recent Admin Logs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Card(
             child: ListTile(
               leading: Icon(Icons.update_outlined),
               title: Text('No recent logs available'),
               subtitle: Text('Your administrative actions will appear here.'),
             ),
          ),
          const SizedBox(height: 20),
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

class _ControlListTile extends StatelessWidget {
  const _ControlListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

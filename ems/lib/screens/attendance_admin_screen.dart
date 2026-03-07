import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ems/main.dart';

class AttendanceAdminScreen extends StatefulWidget {
  const AttendanceAdminScreen({super.key});

  @override
  State<AttendanceAdminScreen> createState() => _AttendanceAdminScreenState();
}

class _AttendanceAdminScreenState extends State<AttendanceAdminScreen> {
  List<WeeklyEntry> _weeklyAttendance = [];
  String _userName = 'Admin';
  String _userDepartment = 'Administration';
  String _userRole = 'System Administrator';
  DateTime? _punchInTime;
  DateTime? _punchOutTime;
  Timer? _timer;

  List<dynamic> _allEmployeesData = [];
  List<String> _departments = ['All'];
  String _selectedDepartmentFilter = 'All';

  List<String> _employeeNames = [];
  String? _selectedEmployeeForLog;
  String _selectedTimeFrame = 'Week';

  @override
  void initState() {
    super.initState();
    _loadUserAndAttendance();
    _fetchEmployees();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _fetchEmployees() async {
    try {
      String baseUrl = 'https://employee-management-system-tefv.onrender.com';
      if (!kIsWeb && Platform.isAndroid) baseUrl = 'https://employee-management-system-tefv.onrender.com';
      final response = await http.get(Uri.parse('$baseUrl/api/employees'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> depts = data.map((e) => (e['department'] ?? '').toString()).where((d) => d.isNotEmpty).toList();
        
        if (mounted) {
          setState(() {
            _allEmployeesData = data;
            _departments = ['All', ...depts.toSet().toList()];
            _updateEmployeeNamesList();
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch employees error: $e");
    }
  }

  void _updateEmployeeNamesList({bool triggerFetch = false}) {
    List<dynamic> filteredData = _allEmployeesData;
    if (_selectedDepartmentFilter != 'All') {
      filteredData = _allEmployeesData.where((e) => e['department'] == _selectedDepartmentFilter).toList();
    }
    List<String> names = filteredData.map((e) => (e['fullName'] ?? '').toString()).where((n) => n.isNotEmpty).toList();
    
    // Ensure Admin's own name is available for fallback, especially if Department is All or matches Admin's Dept
    if (_selectedDepartmentFilter == 'All' || _selectedDepartmentFilter == _userDepartment) {
      if (!names.contains(_userName)) {
         names.insert(0, _userName);
      }
    }
    
    _employeeNames = names.toSet().toList();
    
    if (_selectedEmployeeForLog == null && _employeeNames.isNotEmpty) {
      _selectedEmployeeForLog = _employeeNames.contains(_userName) ? _userName : _employeeNames.first;
    }
    if (_selectedEmployeeForLog != null && !_employeeNames.contains(_selectedEmployeeForLog)) {
      if (_employeeNames.isNotEmpty) {
          _selectedEmployeeForLog = _employeeNames.first;
      } else {
          _selectedEmployeeForLog = null;
      }
    }
    
    if (triggerFetch) {
       _fetchGlobalAttendance();
    }
  }

  Future<void> _loadUserAndAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load local background state first for instant resuming
    final savedPunchIn = prefs.getString('admin_punchIn');
    final savedPunchOut = prefs.getString('admin_punchOut');
    
    DateTime? localPIn;
    DateTime? localPOut;
    
    if (savedPunchIn != null) {
      localPIn = DateTime.parse(savedPunchIn);
      if (savedPunchOut != null) {
        localPOut = DateTime.parse(savedPunchOut);
        DateTime now = DateTime.now();
        if (localPIn.year != now.year || localPIn.month != now.month || localPIn.day != now.day) {
          // Reset if it's a new day AND the previous shift was completed
          localPIn = null;
          localPOut = null;
          prefs.remove('admin_punchIn');
          prefs.remove('admin_punchOut');
        }
      }
    }

    if (mounted) {
      setState(() {
        _userName = prefs.getString('userName') ?? prefs.getString('full_name') ?? 'Admin';
        _selectedEmployeeForLog ??= _userName;
        _userDepartment = prefs.getString('department') ?? prefs.getString('user_department') ?? 'Administration';
        _userRole = prefs.getString('role') ?? prefs.getString('user_role') ?? 'System Administrator';
        if (localPIn != null) _punchInTime = localPIn;
        if (localPOut != null) _punchOutTime = localPOut;
      });
    }
    _fetchGlobalAttendance();
  }

  Future<void> _fetchGlobalAttendance() async {
    try {
      String baseUrl = 'https://employee-management-system-tefv.onrender.com';
      if (!kIsWeb && Platform.isAndroid) baseUrl = 'https://employee-management-system-tefv.onrender.com';

      final response = await http.get(Uri.parse('$baseUrl/api/attendance'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        List<dynamic> adminRecords = [];
        List<dynamic> selectedRecords = [];
        String targetEmployee = _selectedEmployeeForLog ?? _userName;
        
        for (var item in data) {
          if (item['fullName'] == _userName) {
            adminRecords.add(item);
          }
          if (item['fullName'] == targetEmployee) {
            selectedRecords.add(item);
          }
        }

        adminRecords.sort((a, b) => DateTime.parse(b['punchIn']).compareTo(DateTime.parse(a['punchIn'])));
        selectedRecords.sort((a, b) => DateTime.parse(b['punchIn']).compareTo(DateTime.parse(a['punchIn'])));

        DateTime? pIn;
        DateTime? pOut;
        DateTime now = DateTime.now();

        if (adminRecords.isNotEmpty) {
           var latest = adminRecords.first;
           DateTime latestPIn = DateTime.parse(latest['punchIn']).toLocal();
           DateTime? latestPOut = latest['punchOut'] != null ? DateTime.parse(latest['punchOut']).toLocal() : null;
           
           if (latestPOut == null) {
               pIn = latestPIn;
               pOut = null;
           } else if (latestPIn.year == now.year && latestPIn.month == now.month && latestPIn.day == now.day) {
               pIn = latestPIn;
               pOut = latestPOut;
           }
        }
        DateTime startDate;
        DateTime endDate;
        
        if (_selectedTimeFrame == 'Day') {
            startDate = DateTime(now.year, now.month, now.day);
            endDate = startDate;
        } else if (_selectedTimeFrame == 'Month') {
            startDate = DateTime(now.year, now.month, 1);
            endDate = DateTime(now.year, now.month + 1, 0);
        } else if (_selectedTimeFrame == 'Year') {
            startDate = DateTime(now.year, 1, 1);
            endDate = DateTime(now.year, 12, 31);
        } else {
            int currentWeekday = now.weekday;
            startDate = now.subtract(Duration(days: currentWeekday - 1));
            startDate = DateTime(startDate.year, startDate.month, startDate.day);
            endDate = startDate.add(const Duration(days: 6));
        }

        List<WeeklyEntry> weekData = [];
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        
        final List<DateTime> publicHolidays = [
          DateTime(now.year, 3, 4), // Holi
        ];

        int totalDays = endDate.difference(startDate).inDays + 1;
        DateTime today = DateTime(now.year, now.month, now.day);
        
        for (int i=0; i<totalDays; i++) {
           DateTime currDate = startDate.add(Duration(days: i));
           String dayName = dayNames[currDate.weekday - 1];
           
           if (_selectedTimeFrame == 'Year' && currDate.isAfter(today)) {
               break; 
           }
           
           if (currDate.weekday == 6 || currDate.weekday == 7) { 
              weekData.add(WeeklyEntry(day: dayName, date: currDate, status: 'Weekend', time: '-'));
              continue;
           }
           
           bool isHoliday = publicHolidays.any((holiday) => 
               holiday.year == currDate.year && holiday.month == currDate.month && holiday.day == currDate.day);
           
           var dailyRecord = selectedRecords.where((r) {
               DateTime pInDt = DateTime.parse(r['punchIn']).toLocal();
               return pInDt.year == currDate.year && pInDt.month == currDate.month && pInDt.day == currDate.day;
           }).toList();
           
           if (dailyRecord.isNotEmpty) {
               var r = dailyRecord.first;
               DateTime pInDt = DateTime.parse(r['punchIn']).toLocal();
               DateTime? pOutDt = r['punchOut'] != null ? DateTime.parse(r['punchOut']).toLocal() : null;
               
               String timeStr = '${pInDt.hour.toString().padLeft(2, '0')}:${pInDt.minute.toString().padLeft(2, '0')}';
               if (pOutDt != null) {
                 timeStr += ' - ${pOutDt.hour.toString().padLeft(2, '0')}:${pOutDt.minute.toString().padLeft(2, '0')}';
               } else {
                 timeStr += ' - Active';
               }
               weekData.add(WeeklyEntry(day: dayName, date: currDate, status: 'Present', time: timeStr));
           } else {
               if (isHoliday) {
                   weekData.add(WeeklyEntry(day: dayName, date: currDate, status: 'Holiday', time: '-'));
               } else {
                   if (currDate.isAfter(today)) {
                       weekData.add(WeeklyEntry(day: dayName, date: currDate, status: '-', time: '-'));
                   } else {
                       weekData.add(WeeklyEntry(day: dayName, date: currDate, status: 'Absent', time: '-'));
                   }
               }
           }
        }

        if (_selectedTimeFrame == 'Month' || _selectedTimeFrame == 'Year') {
           weekData = weekData.reversed.toList();
        }

        if (mounted) {
          setState(() {
            _weeklyAttendance = weekData;
            _punchInTime = pIn;
            _punchOutTime = pOut;
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch attendance error: $e");
    }
  }

  Future<void> _punchIn() async {
    try {
      String baseUrl = 'https://employee-management-system-tefv.onrender.com';
      if (!kIsWeb && Platform.isAndroid) baseUrl = 'https://employee-management-system-tefv.onrender.com';
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance/punch-in'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': _userName,
          'department': _userDepartment,
          'role': _userRole,
        }),
      );

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        final serverTimeStr = json.decode(response.body)['punchIn'];
        
        await prefs.setString('admin_punchIn', serverTimeStr);
        
        setState(() {
          _punchInTime = DateTime.parse(serverTimeStr).toLocal();
        });

        // Add beautiful local notification
        final String notificationPayload = json.encode({
          'title': 'Attendance Marked',
          'message': 'You have successfully punched in! Have a great day ahead.',
          'timestamp': DateTime.now().toIso8601String(),
          'time': 'Just now',
          'category': 'Attendance',
          'isUnread': true,
          'icon': 'fact_check',
        });

        List<String> notifications = prefs.getStringList('notifications_list') ?? [];
        notifications.insert(0, notificationPayload);
        await prefs.setStringList('notifications_list', notifications);

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'ems_attendance_channel',
          'Attendance Notifications',
          channelDescription: 'Notifications for punch in/out events',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          timeoutAfter: 15000,
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        try {
          await flutterLocalNotificationsPlugin.show(
            1,
            'Attendance Marked',
            'You have successfully punched in! Have a great day ahead.',
            platformChannelSpecifics,
            payload: notificationPayload,
          );
        } catch (e) {
          // ignore notification error if any
        }

        _fetchGlobalAttendance();
      }
    } catch (e) {
      debugPrint("Punch in error: $e");
    }
  }

  Future<void> _punchOut() async {
    try {
      String baseUrl = 'https://employee-management-system-tefv.onrender.com';
      if (!kIsWeb && Platform.isAndroid) baseUrl = 'https://employee-management-system-tefv.onrender.com';
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance/punch-out'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fullName': _userName}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final serverTimeStr = json.decode(response.body)['punchOut'];

        await prefs.setString('admin_punchOut', serverTimeStr);

        setState(() {
          _punchOutTime = DateTime.parse(serverTimeStr).toLocal();
        });

        // Add beautiful local notification
        final String notificationPayload = json.encode({
          'title': 'Attendance Completed',
          'message': 'You have successfully punched out! Goodbye and rest well.',
          'timestamp': DateTime.now().toIso8601String(),
          'time': 'Just now',
          'category': 'Attendance',
          'isUnread': true,
          'icon': 'fact_check',
        });

        List<String> notifications = prefs.getStringList('notifications_list') ?? [];
        notifications.insert(0, notificationPayload);
        await prefs.setStringList('notifications_list', notifications);

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'ems_attendance_channel',
          'Attendance Notifications',
          channelDescription: 'Notifications for punch in/out events',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          timeoutAfter: 15000,
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        try {
          await flutterLocalNotificationsPlugin.show(
            2,
            'Attendance Completed',
            'You have successfully punched out! Goodbye and rest well.',
            platformChannelSpecifics,
            payload: notificationPayload,
          );
        } catch (e) {
          // ignore notification error if any
        }

        _fetchGlobalAttendance();
      }
    } catch (e) {
      debugPrint("Punch out error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // No filtered attendance anymore

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant Header Section
          Text(
            'Company Attendance Hub',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Live monitoring for ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),

          // Admin Personal Attendance Card
          _buildPersonalAttendanceCard(),
          const SizedBox(height: 24),
          // Weekly Log filter replacement for Current User
          Text(
            'Attendance Records',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Department',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true,
            value: _selectedDepartmentFilter,
            items: _departments.map((dept) => DropdownMenuItem(
              value: dept,
              child: Text(dept, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedDepartmentFilter = val;
                  _updateEmployeeNamesList(triggerFetch: true);
                });
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  value: (_employeeNames.isNotEmpty && _selectedEmployeeForLog != null && _employeeNames.contains(_selectedEmployeeForLog)) ? _selectedEmployeeForLog : null,
                  items: _employeeNames.map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedEmployeeForLog = val;
                      });
                      _fetchGlobalAttendance();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedTimeFrame,
                  items: ['Day', 'Week', 'Month', 'Year'].map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTimeFrame = val;
                      });
                      _fetchGlobalAttendance();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_weeklyAttendance.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No logs right now',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _weeklyAttendance.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _WeeklyAttendanceTile(entry: _weeklyAttendance[index]);
              },
            ),

          const SizedBox(height: 32),

          // Leave Management Shortcut
          Text(
            'Off-Duty Personnel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (_onLeaveEmployees.isEmpty)
             const Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text('All personnel are currently available.'),
                ),
              ),
            )
          else
            ..._onLeaveEmployees.map((entry) => _AdminLeaveTile(entry: entry)),
            
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPersonalAttendanceCard() {
    final refNow = DateTime.now();
    Duration activeDuration = Duration.zero;
    if (_punchInTime != null) {
      if (_punchOutTime != null) {
        activeDuration = _punchOutTime!.difference(_punchInTime!);
      } else {
        activeDuration = refNow.difference(_punchInTime!);
      }
    }

    final targetDuration = const Duration(hours: 9);
    double adminProgress = activeDuration.inSeconds / targetDuration.inSeconds;
    if (adminProgress > 1.0) adminProgress = 1.0;

    Color progressColor = Theme.of(context).colorScheme.primary;

    if (_punchInTime == null) {
      if (refNow.hour >= 23 && refNow.minute >= 59) {
        progressColor = Colors.red;
        adminProgress = 1.0;
      } else {
        adminProgress = 0.0;
      }
    } else if (_punchOutTime != null) {
      if (activeDuration >= targetDuration) {
        progressColor = Colors.green;
      } else {
        progressColor = Colors.orange;
      }
    } else {
      progressColor = Colors.green;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Attendance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_punchInTime != null)
                  Builder(builder: (context) {
                    String statusText = 'Active';
                    Color statusColor = Colors.green;

                    if (_punchOutTime != null) {
                      if (activeDuration >= targetDuration) {
                        statusText = 'Completed';
                        statusColor = Colors.green;
                      } else {
                        statusText = 'Half Day';
                        statusColor = Colors.orange;
                      }
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Required: 9 Hours',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _formatDuration(activeDuration),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: adminProgress,
                minHeight: 12,
                backgroundColor: progressColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _punchInTime == null
                      ? Theme.of(context).colorScheme.primary
                      : (_punchOutTime == null ? Colors.orange : Colors.grey),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _punchOutTime != null
                    ? null
                    : () {
                          if (_punchInTime == null) {
                            _punchIn();
                          } else if (_punchOutTime == null) {
                            _punchOut();
                          }
                      },
                child: Text(
                  _punchInTime == null
                      ? 'Punch In'
                      : (_punchOutTime == null
                          ? 'Punch Out'
                          : 'Attendance Marked'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyAttendanceTile extends StatelessWidget {
  const _WeeklyAttendanceTile({required this.entry});

  final WeeklyEntry entry;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    if (entry.status == 'Present') {
      statusColor = Colors.green.shade600;
      statusIcon = Icons.check_circle;
    } else if (entry.status == 'Absent') {
      statusColor = Colors.red.shade600;
      statusIcon = Icons.cancel;
    } else if (entry.status == 'Weekend') {
      statusColor = Colors.blue.shade600;
      statusIcon = Icons.weekend;
    } else if (entry.status == 'Holiday') {
      statusColor = Colors.purple.shade500;
      statusIcon = Icons.celebration;
    } else {
      statusColor = Colors.grey.shade600;
      statusIcon = Icons.schedule;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          entry.day,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text(entry.time),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text('${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}'),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            entry.status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminLeaveTile extends StatelessWidget {
  const _AdminLeaveTile({required this.entry});

  final LeaveEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          child: Icon(
            Icons.beach_access,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${entry.type} • ${entry.days}'),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

class WeeklyEntry {
  const WeeklyEntry({
    required this.day,
    required this.date,
    required this.status,
    required this.time,
  });

  final String day;
  final DateTime date;
  final String status;
  final String time;
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

const List<LeaveEntry> _onLeaveEmployees = [];

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserAndAttendance();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
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
        _userName = prefs.getString('userName') ?? 'Admin';
        _userDepartment = prefs.getString('department') ?? 'Administration';
        _userRole = prefs.getString('role') ?? 'System Administrator';
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
        List<dynamic> myRecords = [];
        
        for (var item in data) {
          if (item['fullName'] == _userName) {
            myRecords.add(item);
          }
        }

        // Sort records descending by punch_in time to find the most recent
        myRecords.sort((a, b) => DateTime.parse(b['punchIn']).compareTo(DateTime.parse(a['punchIn'])));

        DateTime? pIn;
        DateTime? pOut;
        DateTime now = DateTime.now();

        if (myRecords.isNotEmpty) {
           var latest = myRecords.first;
           DateTime latestPIn = DateTime.parse(latest['punchIn']).toLocal();
           DateTime? latestPOut = latest['punchOut'] != null ? DateTime.parse(latest['punchOut']).toLocal() : null;
           
           if (latestPOut == null) {
               // Active shift, even if from yesterday
               pIn = latestPIn;
               pOut = null;
           } else if (latestPIn.year == now.year && latestPIn.month == now.month && latestPIn.day == now.day) {
               // Completed shift that started today
               pIn = latestPIn;
               pOut = latestPOut;
           }
        }
        int currentWeekday = now.weekday;
        DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
        monday = DateTime(monday.year, monday.month, monday.day);
        
        List<WeeklyEntry> weekData = [];
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        
        // Example dynamic public holidays
        final List<DateTime> publicHolidays = [
          DateTime(now.year, 3, 4), // Holi
        ];
        
        for (int i=0; i<7; i++) {
           DateTime currDate = monday.add(Duration(days: i));
           String dayName = dayNames[i];
           
           if (i == 5 || i == 6) { // Sat, Sun (Weekend takes precedence)
              weekData.add(WeeklyEntry(day: dayName, date: currDate, status: 'Weekend', time: '-'));
              continue;
           }
           
           bool isHoliday = publicHolidays.any((holiday) => 
               holiday.year == currDate.year && holiday.month == currDate.month && holiday.day == currDate.day);
           
           var dailyRecord = myRecords.where((r) {
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
                   DateTime today = DateTime(now.year, now.month, now.day);
                   if (currDate.isAfter(today)) {
                       weekData.add(WeeklyEntry(day: dayName, date: currDate, status: '-', time: '-'));
                   } else {
                       weekData.add(WeeklyEntry(day: dayName, date: currDate, status: 'Absent', time: '-'));
                   }
               }
           }
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
            'My Weekly Logs',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
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

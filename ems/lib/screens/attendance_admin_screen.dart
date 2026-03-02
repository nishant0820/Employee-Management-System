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
  String _statusFilter = 'All';

  List<String> get _statusFilters {
    final statuses =
        _liveAttendance.map((entry) => entry.status).toSet().toList()..sort();
    return ['All', ...statuses];
  }

  List<AttendanceEntry> _liveAttendance = [];
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
      if (localPIn.day != DateTime.now().day) {
        // Reset if it's a new day
        localPIn = null;
        prefs.remove('admin_punchIn');
        prefs.remove('admin_punchOut');
      } else if (savedPunchOut != null) {
        localPOut = DateTime.parse(savedPunchOut);
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
        List<AttendanceEntry> loaded = [];
        
        DateTime? pIn;
        DateTime? pOut;

        for (var item in data) {
          final itemPunchIn = DateTime.parse(item['punchIn']).toLocal();
          DateTime? itemPunchOut = item['punchOut'] != null ? DateTime.parse(item['punchOut']).toLocal() : null;

          if (item['fullName'] == _userName && pIn == null) {
            // Find my active/latest session
            pIn = itemPunchIn;
            pOut = itemPunchOut;
            // Only capture the most recent today
            if (pIn.day != DateTime.now().day) {
               pIn = null;
               pOut = null;
            }
          }

          String timeStr = '${itemPunchIn.hour.toString().padLeft(2, '0')}:${itemPunchIn.minute.toString().padLeft(2, '0')}';
          if (itemPunchOut != null) {
            timeStr += ' - ${itemPunchOut.hour.toString().padLeft(2, '0')}:${itemPunchOut.minute.toString().padLeft(2, '0')}';
          } else {
             timeStr += ' - Active';
          }

          String statusLabel = item['status'] ?? 'Present';
          if (itemPunchOut == null) statusLabel = 'On Time'; // visual override while active

          loaded.add(AttendanceEntry(
            name: item['fullName'] ?? 'Unknown',
            time: timeStr,
            department: item['department'] ?? 'Unknown',
            status: statusLabel,
          ));
        }

        if (mounted) {
          setState(() {
            _liveAttendance = loaded;
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
    final filteredAttendance = _statusFilter == 'All'
        ? _liveAttendance
        : _liveAttendance
            .where((entry) => entry.status == _statusFilter)
            .toList();

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
          // Filter chips
          Text(
            'Live Log Filter',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((label) {
                final isSelected = _statusFilter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _statusFilter = label);
                    },
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Interactive List of logs
          if (filteredAttendance.isEmpty)
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
                      'No $_statusFilter logs right now',
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
              itemCount: filteredAttendance.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _AdminCheckInTile(entry: filteredAttendance[index]);
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

class _AdminCheckInTile extends StatelessWidget {
  const _AdminCheckInTile({required this.entry});

  final AttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            entry.name[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          entry.name,
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
              Icon(Icons.business, size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  entry.department,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(entry.status, context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            entry.status,
            style: TextStyle(
              color: _getStatusColor(entry.status, context),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    if (status == 'On Time' || status == 'Present') return Colors.green.shade600;
    if (status == 'Late' || status == 'Half Day') return Colors.orange.shade700;
    if (status == 'Absent') return Colors.red.shade600;
    return Theme.of(context).colorScheme.primary;
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

const List<LeaveEntry> _onLeaveEmployees = [];

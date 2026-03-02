import 'package:flutter/material.dart';

class AttendanceAdminScreen extends StatefulWidget {
  const AttendanceAdminScreen({super.key});

  @override
  State<AttendanceAdminScreen> createState() => _AttendanceAdminScreenState();
}

class _AttendanceAdminScreenState extends State<AttendanceAdminScreen> {
  String _statusFilter = 'All';

  List<String> get _statusFilters {
    final statuses =
        _recentAttendance.map((entry) => entry.status).toSet().toList()..sort();
    return ['All', ...statuses];
  }

  @override
  Widget build(BuildContext context) {
    final int presentEmployees = _recentAttendance.length;
    final int onLeaveCount = _onLeaveEmployees.length;
    final int totalEmployees = presentEmployees + onLeaveCount;
    final attendanceRate =
        totalEmployees == 0 ? 0.0 : presentEmployees / totalEmployees;

    final filteredAttendance = _statusFilter == 'All'
        ? _recentAttendance
        : _recentAttendance
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

          // Primary overview card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Global Check-in Rate',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(attendanceRate * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: attendanceRate,
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$presentEmployees Active',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$onLeaveCount On Leave',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
              Text(entry.department),
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
    if (status == 'On Time') return Colors.green.shade600;
    if (status == 'Late') return Colors.orange.shade700;
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

const List<AttendanceEntry> _recentAttendance = [];
const List<LeaveEntry> _onLeaveEmployees = [];

import 'package:flutter/material.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<DepartmentInfo> _departments = [];

  List<DepartmentInfo> get _filteredDepartments {
    if (_searchQuery.isEmpty) {
      return _departments;
    }
    return _departments.where((dept) {
      return dept.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dept.head.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int get _totalEmployees {
    return _departments.fold(0, (sum, dept) => sum + dept.employeeCount);
  }

  int get _totalProjects {
    return _departments.fold(0, (sum, dept) => sum + dept.activeProjects);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredDepts = _filteredDepartments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.corporate_fare,
                  label: 'Departments',
                  value: '${_departments.length}',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                _StatItem(
                  icon: Icons.people_outline,
                  label: 'Total Staff',
                  value: '$_totalEmployees',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                _StatItem(
                  icon: Icons.work_outline,
                  label: 'Projects',
                  value: '$_totalProjects',
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search departments...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Department List
          Expanded(
            child: filteredDepts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No departments found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDepts.length,
                    itemBuilder: (context, index) {
                      return _DepartmentCard(department: filteredDepts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({required this.department});

  final DepartmentInfo department;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showDepartmentDetails(context, department);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Department Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: department.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  department.icon,
                  color: department.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Department Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          department.head,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.people,
                          label: '${department.employeeCount} Staff',
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.work,
                          label: '${department.activeProjects} Projects',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepartmentDetails(BuildContext context, DepartmentInfo dept) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dept.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        dept.icon,
                        color: dept.color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dept.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Department Head',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: dept.color.withValues(alpha: 0.2),
                      child: Text(
                        dept.head.substring(0, 1),
                        style: TextStyle(
                          color: dept.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(dept.head),
                    subtitle: Text('${dept.name} Manager'),
                    trailing: IconButton(
                      icon: const Icon(Icons.email_outlined),
                      onPressed: () {},
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DetailStatCard(
                        icon: Icons.people,
                        label: 'Total Staff',
                        value: '${dept.employeeCount}',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailStatCard(
                        icon: Icons.work,
                        label: 'Active Projects',
                        value: '${dept.activeProjects}',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing ${dept.name} details'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Full Details'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  const _DetailStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DepartmentInfo {
  final String name;
  final IconData icon;
  final Color color;
  final int employeeCount;
  final String head;
  final String description;
  final int activeProjects;

  DepartmentInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.employeeCount,
    required this.head,
    required this.description,
    required this.activeProjects,
  });
}

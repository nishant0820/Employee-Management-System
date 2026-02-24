import 'package:flutter/material.dart';
import 'package:ems/screens/dashboard_screen.dart';
import 'package:ems/screens/employees_screen.dart';
import 'package:ems/screens/attendance_screen.dart';
import 'package:ems/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  static const List<String> _titles = [
    'Dashboard',
    'Employees',
    'Attendance',
    'Profile',
  ];

  static const List<Widget> _screens = [
    DashboardScreen(),
    EmployeesScreen(),
    AttendanceScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == _currentIndex) return;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_2_outlined),
            selectedIcon: Icon(Icons.groups_2),
            label: 'Employees',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

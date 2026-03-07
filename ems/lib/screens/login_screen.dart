import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ems/main.dart'; // to get flutterLocalNotificationsPlugin
import 'package:ems/screens/main_screen.dart';
import 'package:ems/screens/main_screen_admin.dart';
import 'package:ems/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _selectedDepartment;
  String? _selectedRole;
  final List<String> _departments = ['HR', 'Admin', 'Employee'];

  final Map<String, List<String>> _rolesMap = {
    'HR': [
      'Recruitment and Talent Acquisition',
      'HR Operations',
      'Payroll and Compensation',
      'Learning & development',
      'Performance management',
    ],
    'Admin': ['System Administrator', 'Finance Manager', 'Operations Lead'],
    'Employee': [
      'Software Engineer',
      'Sales Representative',
      'Customer Support',
      'Marketing Specialist',
    ],
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String baseUrl = 'https://employee-management-system-tefv.onrender.com';
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          baseUrl =
              'https://employee-management-system-tefv.onrender.com'; // Or 10.0.2.2 usually
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'department': _selectedDepartment,
          'role': _selectedRole,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Parse login response
        final responseData = json.decode(response.body);
        String token = responseData['token'];
        String department = responseData['department'];
        String role = responseData['role'] ?? '';
        String fullName = responseData['fullName'] ?? 'User';
        String email = responseData['email'] ?? '';
        String phone = responseData['phoneNumber'] ?? '';

        // Save the token persistently
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_department', department);
        await prefs.setString('user_role', role);
        await prefs.setString('full_name', fullName);
        await prefs.setString('user_email', email);
        await prefs.setString('user_phone', phone);
        await prefs.setString('login_time', DateTime.now().toIso8601String());
        await prefs.setBool('is_new_user', false);

        final String notificationPayload = json.encode({
          'title': 'Welcome Back, $fullName!',
          'message': 'You have successfully logged in to the EMS portal.',
          'timestamp': DateTime.now().toIso8601String(),
          'time': 'Just now',
          'category': 'System',
          'isUnread': true,
          'icon': 'login',
        });

        List<String> notifications =
            prefs.getStringList('notifications_list') ?? [];
        notifications.insert(0, notificationPayload);
        await prefs.setStringList('notifications_list', notifications);

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'ems_login_channel',
          'Login Notifications',
          channelDescription: 'Notifications for login events',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          timeoutAfter: 15000,
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        try {
          await flutterLocalNotificationsPlugin.show(
            0,
            'Welcome Back, $fullName!',
            'You have successfully logged in to the EMS portal.',
            platformChannelSpecifics,
            payload: notificationPayload,
          );
        } catch (e) {
          // ignore notification error if any
        }

        List<String> loginActivity =
            prefs.getStringList('login_activity_list') ?? [];
        loginActivity.insert(
          0,
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'device': kIsWeb ? 'Web Browser' : Platform.operatingSystem,
          }),
        );
        await prefs.setStringList('login_activity_list', loginActivity);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Login Successful'),
                ],
              ),
              content: Text('Welcome back to the EMS portal, $fullName!'),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );

        if (department == 'Admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreenAdmin()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not connect to the server.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Image or Icon
                  Icon(Icons.lock_person, size: 80, color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to your HR Dashboard',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email Address
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Department Selection
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _departments
                        .map(
                          (dept) =>
                              DropdownMenuItem(value: dept, child: Text(dept)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedDepartment = value;
                        _selectedRole =
                            null; // Reset role when department changes
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role Selection
                  if (_selectedDepartment != null) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.work_outline),
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: (_rolesMap[_selectedDepartment] ?? [])
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedRole = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log In', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),

                  // Signup Navigation Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

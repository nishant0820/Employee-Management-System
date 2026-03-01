import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ems/screens/notifications_screen.dart';
import 'package:ems/screens/edit_profile_screen.dart';
import 'package:ems/screens/change_password_screen.dart';
import 'package:ems/screens/portal_settings_screen.dart';
import 'package:ems/screens/login_screen.dart';
import 'package:ems/screens/login_activity_screen.dart';
import 'package:ems/widgets/gradient_button.dart';

class ProfileScreen extends StatefulWidget {
	const ProfileScreen({super.key});

	@override
	State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
	bool _pushNotifications = true;
	bool _emailUpdates = true;
	bool _biometricLogin = false;
	String? _profileName;
	String? _profileEmail;
	int? _teamSize;
	int? _pendingReviews;
	String? _employeeId;
	String? _department;
	String? _role;
	String? _shift;

	int _unreadNotifications = 0;

	@override
	void initState() {
		super.initState();
		_loadUserData();
		_fetchUnreadCount();
	}

	Future<void> _fetchUnreadCount() async {
		final prefs = await SharedPreferences.getInstance();
		final List<String> saved = prefs.getStringList('notifications_list') ?? [];
		int count = 0;
		for (var str in saved) {
			try {
				final data = json.decode(str);
				if (data['isUnread'] == true) {
					count++;
				}
			} catch (e) {
				// skip corrupt ones
			}
		}
		if (mounted) {
			setState(() {
				_unreadNotifications = count;
			});
		}
	}

	Future<void> _loadUserData() async {
		final prefs = await SharedPreferences.getInstance();
		final fullName = prefs.getString('full_name');
		final userEmail = prefs.getString('user_email');
		final userDepartment = prefs.getString('user_department');
		final userRole = prefs.getString('user_role');
		
		if (mounted) {
			setState(() {
				if (fullName != null && fullName.isNotEmpty) _profileName = fullName;
				if (userEmail != null && userEmail.isNotEmpty) _profileEmail = userEmail;
				if (userDepartment != null && userDepartment.isNotEmpty) _department = userDepartment;
				if (userRole != null && userRole.isNotEmpty) _role = userRole;
			});
		}
	}

	Future<void> _logout() async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.clear(); // Clears all saved user session data including auth_token
		
		if (!mounted) return;

		Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
			MaterialPageRoute(builder: (_) => const LoginScreen()),
			(route) => false,
		);
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		final avatarLabel = _profileName == null || _profileName!.trim().isEmpty
				? '?'
				: _profileName!.trim().substring(0, 1).toUpperCase();

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								children: [
									Row(
										children: [
											CircleAvatar(
												radius: 32,
												backgroundColor: colorScheme.primaryContainer,
												child: Text(
													avatarLabel,
													style: TextStyle(
														color: colorScheme.onPrimaryContainer,
														fontSize: 24,
														fontWeight: FontWeight.w600,
													),
												),
											),
											const SizedBox(width: 14),
											Expanded(
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text(
															_profileName ?? 'Not set',
															style: Theme.of(context).textTheme.titleLarge,
														),
														const SizedBox(height: 4),
														Text(
															_role != null && _role!.isNotEmpty ? _role! : (_department ?? 'Not set'),
															style: Theme.of(context).textTheme.bodyMedium,
														),
														const SizedBox(height: 2),
														Text(
															_profileEmail ?? 'Not set',
															style: Theme.of(context).textTheme.bodySmall,
														),
													],
												),
											),
										],
									),
									const SizedBox(height: 14),
									Row(
										children: [
											Expanded(
												child: _ProfileStatTile(
													title: 'Team Size',
													value: '${_teamSize ?? 0}',
													icon: Icons.groups_outlined,
												),
											),
											const SizedBox(width: 10),
											Expanded(
												child: _ProfileStatTile(
													title: 'Pending Reviews',
													value: '${_pendingReviews ?? 0}',
													icon: Icons.assignment_late_outlined,
												),
											),
										],
									),
								],
							),
						),
					),
					const SizedBox(height: 12),
					Row(
						children: [
							Expanded(
								child: GradientButton(
									label: _unreadNotifications > 0 
										? 'View Notifications ($_unreadNotifications)' 
										: 'View Notifications',
									icon: _unreadNotifications > 0 
										? Icons.notifications_active 
										: Icons.notifications_outlined,
									height: 46,
									onPressed: () async {
										await Navigator.of(context).push(
											MaterialPageRoute(
												builder: (_) => const NotificationsScreen(),
											),
										);
										_fetchUnreadCount(); // Refresh count when returning
									},
								),
							),
						],
					),
					const SizedBox(height: 16),
					Text(
						'Account',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 8),
					_SettingsTile(
						icon: Icons.person_outline,
						title: 'Edit Profile',
						subtitle: 'Update your personal information',
						onTap: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (_) => const EditProfileScreen(),
								),
							);
						},
					),
					_SettingsTile(
						icon: Icons.lock_outline,
						title: 'Change Password',
						subtitle: 'Update account password regularly',
						onTap: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (_) => const ChangePasswordScreen(),
								),
							);
						},
					),
					_SettingsTile(
						icon: Icons.history_toggle_off,
						title: 'Login Activity',
						subtitle: 'Review recent account sessions',
						onTap: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (_) => const LoginActivityScreen(),
								),
							);
						},
					),
					_SettingsTile(
						icon: Icons.settings_outlined,
						title: 'Portal Settings',
						subtitle: 'Language, timezone, and preferences',
						onTap: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (_) => const PortalSettingsScreen(),
								),
							);
						},
					),
					const SizedBox(height: 16),
					Text(
						'Preferences',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 8),
					Card(
						child: Column(
							children: [
								SwitchListTile(
									value: _pushNotifications,
									title: const Text('Push Notifications'),
									subtitle: const Text('Receive real-time attendance alerts'),
									onChanged: (value) {
										setState(() => _pushNotifications = value);
									},
								),
								SwitchListTile(
									value: _emailUpdates,
									title: const Text('Email Updates'),
									subtitle: const Text('Weekly team summary to your inbox'),
									onChanged: (value) {
										setState(() => _emailUpdates = value);
									},
								),
								SwitchListTile(
									value: _biometricLogin,
									title: const Text('Biometric Login'),
									subtitle: const Text('Use fingerprint/face unlock on this device'),
									onChanged: (value) {
										setState(() => _biometricLogin = value);
									},
								),
							],
						),
					),
					const SizedBox(height: 16),
					Text(
						'Work Information',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 8),
					_SettingsTile(
						icon: Icons.badge_outlined,
						title: 'Employee ID',
						subtitle: _employeeId ?? 'Not set',
					),
					_SettingsTile(
						icon: Icons.apartment_outlined,
						title: 'Department',
						subtitle: _department ?? 'Not set',
					),
					_SettingsTile(
						icon: Icons.work_outline,
						title: 'Role',
						subtitle: _role ?? 'Not set',
					),
					_SettingsTile(
						icon: Icons.schedule_outlined,
						title: 'Shift',
						subtitle: _shift ?? 'Not set',
					),
					const SizedBox(height: 18),
					SizedBox(
						width: double.infinity,
						child: OutlinedButton.icon(
							onPressed: _logout,
							icon: const Icon(Icons.logout),
							label: const Text('Log Out'),
						),
					),
				],
			),
		);
	}
}

class _ProfileStatTile extends StatelessWidget {
	const _ProfileStatTile({
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

		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
				borderRadius: BorderRadius.circular(10),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Icon(icon, size: 20, color: colorScheme.primary),
					const SizedBox(height: 6),
					Text(value, style: Theme.of(context).textTheme.titleLarge),
					Text(title, style: Theme.of(context).textTheme.bodySmall),
				],
			),
		);
	}
}

class _SettingsTile extends StatelessWidget {
	const _SettingsTile({
		required this.icon,
		required this.title,
		required this.subtitle,
		this.onTap,
	});

	final IconData icon;
	final String title;
	final String subtitle;
	final VoidCallback? onTap;

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.symmetric(vertical: 6),
			child: ListTile(
				leading: Icon(icon),
				title: Text(title),
				subtitle: Text(subtitle),
				trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
				onTap: onTap,
			),
		);
	}
}
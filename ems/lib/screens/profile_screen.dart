import 'package:flutter/material.dart';
import 'package:ems/screens/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
	const ProfileScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return SingleChildScrollView(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Row(
								children: [
									CircleAvatar(
										radius: 32,
										backgroundColor: colorScheme.primaryContainer,
										child: Text(
											'A',
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
													'Admin User',
													style: Theme.of(context).textTheme.titleLarge,
												),
												const SizedBox(height: 4),
												Text(
													'HR Administrator',
													style: Theme.of(context).textTheme.bodyMedium,
												),
												const SizedBox(height: 2),
												Text(
													'admin@emsportal.com',
													style: Theme.of(context).textTheme.bodySmall,
												),
											],
										),
									),
								],
							),
						),
					),
					const SizedBox(height: 16),
					Text(
						'Account',
						style: Theme.of(context).textTheme.titleLarge,
					),
					const SizedBox(height: 8),
					const _SettingsTile(
						icon: Icons.person_outline,
						title: 'Edit Profile',
						subtitle: 'Update your personal information',
					),
					const _SettingsTile(
						icon: Icons.lock_outline,
						title: 'Change Password',
						subtitle: 'Update account password regularly',
					),
					_SettingsTile(
						icon: Icons.notifications_outlined,
						title: 'Notifications',
						subtitle: 'Manage push and email alerts',
						onTap: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (_) => const NotificationsScreen(),
								),
							);
						},
					),
					const _SettingsTile(
						icon: Icons.settings_outlined,
						title: 'Portal Settings',
						subtitle: 'Language, timezone, and preferences',
					),
					const SizedBox(height: 18),
					SizedBox(
						width: double.infinity,
						child: OutlinedButton.icon(
							onPressed: () {},
							icon: const Icon(Icons.logout),
							label: const Text('Log Out'),
						),
					),
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
				trailing: const Icon(Icons.chevron_right),
				onTap: onTap,
			),
		);
	}
}

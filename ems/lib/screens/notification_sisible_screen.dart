import 'package:flutter/material.dart';
import 'package:ems/screens/notifications_screen.dart';

class NotificationVisibleScreen extends StatelessWidget {
	const NotificationVisibleScreen({super.key, required this.item});

	final NotificationItem item;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			appBar: AppBar(
				title: const Text('Notification Details'),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(24),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								Container(
									padding: const EdgeInsets.all(16),
									decoration: BoxDecoration(
										color: colorScheme.primaryContainer,
										shape: BoxShape.circle,
									),
									child: Icon(
										item.icon,
										color: colorScheme.onPrimaryContainer,
										size: 32,
									),
								),
								const SizedBox(width: 16),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Container(
												padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
												decoration: BoxDecoration(
													color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													item.category,
													style: Theme.of(context).textTheme.labelMedium?.copyWith(
														color: colorScheme.onSecondaryContainer,
													),
												),
											),
											const SizedBox(height: 8),
											Text(
												formatTimeAgo(item.time),
												style: Theme.of(context).textTheme.bodyMedium?.copyWith(
													color: colorScheme.outline,
												),
											),
										],
									),
								)
							],
						),
						const Divider(height: 48),
						Text(
							item.title,
							style: Theme.of(context).textTheme.headlineSmall?.copyWith(
								fontWeight: FontWeight.bold,
							),
						),
						const SizedBox(height: 16),
						Text(
							item.message,
							style: Theme.of(context).textTheme.bodyLarge?.copyWith(
								height: 1.5,
							),
						),
					],
				),
			),
		);
	}
}

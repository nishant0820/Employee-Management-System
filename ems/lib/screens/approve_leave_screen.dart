import 'package:flutter/material.dart';

class ApproveLeaveScreen extends StatefulWidget {
	const ApproveLeaveScreen({super.key});

	@override
	State<ApproveLeaveScreen> createState() => _ApproveLeaveScreenState();
}

class _ApproveLeaveScreenState extends State<ApproveLeaveScreen> {
	String? _selectedFilter;

	final List<_LeaveRequest> _requests = [];

	List<String> get _filters {
		final filters = _requests.map((request) => request.status).toSet().toList()
			..sort();
		return filters;
	}

	List<_LeaveRequest> _filteredRequests(String? activeFilter) {
		if (activeFilter == null) return _requests;
		return _requests
				.where((request) => request.status == activeFilter)
				.toList();
	}

	void _updateStatus(_LeaveRequest request, String status) {
		setState(() => request.status = status);
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text('Request ${status.toLowerCase()}'),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		final activeFilter = _selectedFilter ?? (_filters.isNotEmpty ? _filters.first : null);
		final requests = _filteredRequests(activeFilter);

		return Scaffold(
			appBar: AppBar(
				title: const Text('Approve Leave'),
				centerTitle: true,
			),
			body: Column(
				children: [
					Padding(
						padding: const EdgeInsets.all(16),
						child: Wrap(
							spacing: 8,
							children: _filters
									.map(
											(filter) => ChoiceChip(
												label: Text(filter),
												selected: activeFilter == filter,
												onSelected: (_) {
													setState(() => _selectedFilter = filter);
												},
											),
									)
									.toList(),
						),
					),
					Expanded(
						child: requests.isEmpty
								? Center(
										child: Text(
											'No requests available',
											style: Theme.of(context).textTheme.titleMedium,
										),
									)
								: ListView.builder(
										padding: const EdgeInsets.symmetric(horizontal: 16),
										itemCount: requests.length,
										itemBuilder: (context, index) {
											final request = requests[index];
											return Card(
												margin: const EdgeInsets.only(bottom: 12),
												child: Padding(
													padding: const EdgeInsets.all(16),
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Row(
																children: [
																	CircleAvatar(
																		backgroundColor:
																			colorScheme.primaryContainer,
																		child: Text(request.name.substring(0, 1)),
																	),
																const SizedBox(width: 12),
																Expanded(
																	child: Column(
																		crossAxisAlignment:
																			CrossAxisAlignment.start,
																		children: [
																				Text(
																					request.name,
																						style: Theme.of(context)
																							.textTheme
																							.titleMedium,
																					),
																					Text(
																						'${request.role} • ${request.department}',
																						style:
																								Theme.of(context)
																									.textTheme
																									.bodySmall,
																					),
																				],
																		),
																),
															],
														),
														const SizedBox(height: 12),
														Row(
															children: [
																Icon(
																	Icons.calendar_today_outlined,
																	size: 16,
																	color: colorScheme.outline,
																),
																const SizedBox(width: 6),
																Text(
																	request.dates,
																	style:
																		Theme.of(context).textTheme.bodySmall,
																),
															],
														),
														const SizedBox(height: 8),
														Text(
															'Reason: ${request.reason}',
															style: Theme.of(context).textTheme.bodySmall,
														),
														const SizedBox(height: 12),
														Row(
															children: [
																Expanded(
																	child: OutlinedButton(
																		onPressed: request.status == 'Rejected'
																			? null
																			: () => _updateStatus(request, 'Rejected'),
																		child: const Text('Reject'),
																	),
																),
																const SizedBox(width: 12),
																Expanded(
																	child: FilledButton(
																		onPressed: request.status == 'Approved'
																			? null
																			: () => _updateStatus(request, 'Approved'),
																		child: const Text('Approve'),
																	),
																),
															],
														),
													],
												),
											),
										);
										},
									),
					),
				],
			),
		);
	}
}

class _LeaveRequest {
	_LeaveRequest({
		required this.name,
		required this.role,
		required this.department,
		required this.dates,
		required this.reason,
		this.status = 'Pending',
	});

	final String name;
	final String role;
	final String department;
	final String dates;
	final String reason;
	String status;
}

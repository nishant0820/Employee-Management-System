import 'package:flutter/material.dart';

class MarkAttendanceScreen extends StatefulWidget {
	const MarkAttendanceScreen({super.key});

	@override
	State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
	String? _selectedShift;
	String? _selectedStatus;
	final TextEditingController _searchController = TextEditingController();
	String _searchQuery = '';

	final List<String> _shifts = [];
	final List<String> _statuses = [];

	final List<_AttendancePerson> _people = [];

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	List<_AttendancePerson> get _filteredPeople {
		if (_searchQuery.isEmpty) return _people;
		return _people
				.where(
					(p) =>
							p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
							p.employeeId.toLowerCase().contains(_searchQuery.toLowerCase()),
				)
				.toList();
	}

	void _markAttendance() {
		ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(
				content: Text('Attendance updated successfully'),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;

		return Scaffold(
			appBar: AppBar(
				title: const Text('Mark Attendance'),
				centerTitle: true,
			),
			body: Column(
				children: [
					Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							children: [
								Row(
									children: [
										Expanded(
											child: DropdownButtonFormField<String>(
												value: _selectedShift,
												decoration: const InputDecoration(
													labelText: 'Shift',
													border: OutlineInputBorder(),
												),
												items: _shifts
														.map((shift) => DropdownMenuItem(
																value: shift,
																child: Text(shift),
															))
														.toList(),
												onChanged: (value) {
													if (value == null) return;
													setState(() => _selectedShift = value);
												},
											),
										),
										const SizedBox(width: 12),
										Expanded(
											child: DropdownButtonFormField<String>(
												value: _selectedStatus,
												decoration: const InputDecoration(
													labelText: 'Status',
													border: OutlineInputBorder(),
												),
												items: _statuses
														.map((status) => DropdownMenuItem(
																value: status,
																child: Text(status),
															))
														.toList(),
												onChanged: (value) {
													if (value == null) return;
													setState(() => _selectedStatus = value);
												},
											),
										),
									],
								),
								const SizedBox(height: 12),
								TextField(
									controller: _searchController,
									onChanged: (value) {
										setState(() => _searchQuery = value);
									},
									decoration: InputDecoration(
										labelText: 'Search employee',
										prefixIcon: const Icon(Icons.search),
										border: const OutlineInputBorder(),
										suffixIcon: _searchQuery.isEmpty
												? null
												: IconButton(
														icon: const Icon(Icons.clear),
														onPressed: () {
															_searchController.clear();
															setState(() => _searchQuery = '');
														},
													),
									),
								),
							],
						),
					),
					Expanded(
						child: _filteredPeople.isEmpty
								? Center(
										child: Text(
											'No employees found',
											style: Theme.of(context).textTheme.titleMedium,
										),
									)
								: ListView.builder(
										padding: const EdgeInsets.symmetric(horizontal: 16),
										itemCount: _filteredPeople.length,
										itemBuilder: (context, index) {
											final person = _filteredPeople[index];
											return Card(
												margin: const EdgeInsets.only(bottom: 12),
												child: ListTile(
													leading: CircleAvatar(
														backgroundColor:
															colorScheme.primaryContainer,
														child: Text(person.name.substring(0, 1)),
													),
													title: Text(person.name),
													subtitle: Text(
														'${person.employeeId} • ${person.department}',
													),
													trailing: DropdownButton<String>(
														value: person.status,
														items: _statuses
																.map((status) => DropdownMenuItem(
																		value: status,
																		child: Text(status),
																))
																.toList(),
														onChanged: (value) {
															if (value == null) return;
															setState(() => person.status = value);
														},
													),
												),
											);
										},
									),
					),
				],
			),
			bottomNavigationBar: Padding(
				padding: const EdgeInsets.all(16),
				child: FilledButton.icon(
					onPressed: _markAttendance,
					icon: const Icon(Icons.check_circle_outline),
					label: const Text('Save Attendance'),
				),
			),
		);
	}
}

class _AttendancePerson {
	_AttendancePerson(this.name, this.employeeId, this.department,
			{this.status = 'Present'});

	final String name;
	final String employeeId;
	final String department;
	String status;
}

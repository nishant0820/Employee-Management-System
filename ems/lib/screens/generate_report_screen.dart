import 'package:flutter/material.dart';

class GenerateReportScreen extends StatefulWidget {
  const GenerateReportScreen({super.key});

  @override
  State<GenerateReportScreen> createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  String? _reportType;
  String? _timeRange;
  bool _includeCharts = true;
  bool _includeEmployeeDetails = true;

  final List<String> _reportTypes = [];

  final List<String> _timeRanges = [];

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report generated successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.assessment_outlined, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Settings',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose report type and time period',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Report Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _reportType,
              decoration: const InputDecoration(
                labelText: 'Select report type',
                border: OutlineInputBorder(),
              ),
              items: _reportTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _reportType = value);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Time Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _timeRanges
                  .map(
                    (range) => ChoiceChip(
                      label: Text(range),
                      selected: _timeRange == range,
                      onSelected: (_) {
                        setState(() => _timeRange = range);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Report Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Include Charts'),
                    subtitle: const Text('Add graphs and visual summaries'),
                    value: _includeCharts,
                    onChanged: (value) {
                      setState(() => _includeCharts = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Employee Details'),
                    subtitle: const Text('Include employee-level breakdowns'),
                    value: _includeEmployeeDetails,
                    onChanged: (value) {
                      setState(() => _includeEmployeeDetails = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Generate Report'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

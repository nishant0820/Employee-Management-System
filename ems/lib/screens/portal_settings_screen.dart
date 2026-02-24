import 'package:flutter/material.dart';
import 'package:ems/themes/theme.dart';

class PortalSettingsScreen extends StatefulWidget {
  const PortalSettingsScreen({super.key});

  @override
  State<PortalSettingsScreen> createState() => _PortalSettingsScreenState();
}

class _PortalSettingsScreenState extends State<PortalSettingsScreen> {
  String? _selectedLanguage;
  String? _selectedTimezone;
  String? _selectedDateFormat;
  String? _selectedTimeFormat;
  String? _selectedTheme;
  bool _compactView = false;
  bool _showAnimations = true;
  bool _autoRefresh = true;

  final List<String> _languages = [];

  final List<String> _timezones = [];

  final List<String> _dateFormats = [];

  final List<String> _timeFormats = [];

  final List<String> _themes = [];

  void _saveSettings() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Close loading dialog
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved successfully!',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedLanguage = null;
                _selectedTimezone = null;
                _selectedDateFormat = null;
                _selectedTimeFormat = null;
                _selectedTheme = null;
                _compactView = false;
                _showAnimations = true;
                _autoRefresh = true;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Customize Your Experience',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure language, timezone, and display preferences',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Localization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: Text(_selectedLanguage ?? 'Not set'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Timezone'),
                    subtitle: Text(_selectedTimezone ?? 'Not set'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showTimezoneDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Date & Time Format',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date Format'),
                    subtitle: Text(_selectedDateFormat ?? 'Not set'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDateFormatDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Time Format'),
                    subtitle: Text(_selectedTimeFormat ?? 'Not set'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showTimeFormatDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(_selectedTheme ?? 'Not set'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.view_compact),
                    title: const Text('Compact View'),
                    subtitle: const Text('Show more content on screen'),
                    value: _compactView,
                    onChanged: (value) {
                      setState(() => _compactView = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.animation),
                    title: const Text('Animations'),
                    subtitle: const Text('Enable smooth transitions'),
                    value: _showAnimations,
                    onChanged: (value) {
                      setState(() => _showAnimations = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data & Sync',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.sync),
                title: const Text('Auto Refresh'),
                subtitle: const Text('Automatically update data in real-time'),
                value: _autoRefresh,
                onChanged: (value) {
                  setState(() => _autoRefresh = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Some settings may require app restart to take full effect',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showTimezoneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Timezone'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              itemCount: _timezones.length,
              itemBuilder: (context, index) {
                final timezone = _timezones[index];
                return RadioListTile<String>(
                  title: Text(timezone),
                  value: timezone,
                  groupValue: _selectedTimezone,
                  onChanged: (value) {
                    setState(() => _selectedTimezone = value);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _dateFormats.length,
            itemBuilder: (context, index) {
              final format = _dateFormats[index];
              return RadioListTile<String>(
                title: Text(format),
                subtitle: Text(_getDateFormatExample(format)),
                value: format,
                groupValue: _selectedDateFormat,
                onChanged: (value) {
                  setState(() => _selectedDateFormat = value);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showTimeFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _timeFormats.map((format) {
            return RadioListTile<String>(
              title: Text(format),
              subtitle: Text(_getTimeFormatExample(format)),
              value: format,
              groupValue: _selectedTimeFormat,
              onChanged: (value) {
                setState(() => _selectedTimeFormat = value);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _themes.map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: _selectedTheme,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedTheme = value);
                ThemeManager().setThemeMode(value);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getDateFormatExample(String format) {
    return '';
  }

  String _getTimeFormatExample(String format) {
    return '';
  }
}

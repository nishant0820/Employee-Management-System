import 'package:flutter/material.dart';
import 'package:ems/widgets/gradient_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  int _getPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  Color _getStrengthColor(int strength) {
    if (strength <= 2) return Colors.red;
    if (strength <= 4) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText(int strength) {
    if (strength <= 2) return 'Weak';
    if (strength <= 4) return 'Moderate';
    return 'Strong';
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final newPassword = _newPasswordController.text;
    final strength = _getPasswordStrength(newPassword);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Update Your Password',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a strong password to keep your account secure',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Current Password',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                validator: _validateCurrentPassword,
                decoration: InputDecoration(
                  hintText: 'Enter your current password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'New Password',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                validator: _validateNewPassword,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Enter your new password',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              if (newPassword.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: strength / 6,
                        backgroundColor: Colors.grey.withValues(alpha: 0.3),
                        color: _getStrengthColor(strength),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getStrengthText(strength),
                      style: TextStyle(
                        color: _getStrengthColor(strength),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Confirm New Password',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Re-enter your new password',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Password Requirements',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _RequirementRow(
                        text: 'At least 8 characters',
                        met: newPassword.length >= 8,
                      ),
                      _RequirementRow(
                        text: 'One uppercase letter (A-Z)',
                        met: RegExp(r'[A-Z]').hasMatch(newPassword),
                      ),
                      _RequirementRow(
                        text: 'One lowercase letter (a-z)',
                        met: RegExp(r'[a-z]').hasMatch(newPassword),
                      ),
                      _RequirementRow(
                        text: 'One number (0-9)',
                        met: RegExp(r'[0-9]').hasMatch(newPassword),
                      ),
                      _RequirementRow(
                        text: 'One special character (!@#\$%^&*)',
                        met: RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                            .hasMatch(newPassword),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Change Password',
                  icon: Icons.check,
                  onPressed: _changePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.text,
    required this.met,
  });

  final String text;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: met ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.green : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

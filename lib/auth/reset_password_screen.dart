import 'package:flutter/material.dart';

import '../core/app_dependencies.dart';
import '../core/constants/colors.dart';
import '../core/widgets/app_gradient_scaffold.dart';
import '../core/utils/password_utils.dart';
import '../core/widgets/app_primary_button.dart';
import '../core/widgets/app_text_input.dart';
import '../core/widgets/auth_card.dart';
import '../core/widgets/password_feedback.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(
      authRepository: AppDependencies.authRepository,
      profileRepository: AppDependencies.profileRepository,
      progressRepository: AppDependencies.progressRepository,
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.updatePassword(
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );
    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully.'),
        backgroundColor: Colors.green,
      ),
    );
    await _controller.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _passwordController]),
        builder: (context, _) {
          return AuthCard(
            title: 'Set New Password',
            subtitle: 'Enter your new password below',
            header: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Tip: choose a password different from your previous one for better security.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextInput(
                    controller: _passwordController,
                    label: 'New Password',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) => PasswordUtils.validate(
                      value?.trim() ?? '',
                      email: AppDependencies.authRepository
                          .getCurrentUser()
                          ?.email,
                      requireStrong: true,
                    ).errorMessage,
                  ),
                  const SizedBox(height: 8),
                  if (password.isNotEmpty) ...[
                    PasswordStrengthIndicator(
                      strength: PasswordUtils.strengthFor(password),
                    ),
                    const SizedBox(height: 8),
                    PasswordRequirements(password: password),
                  ],
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _updatePassword(),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Please confirm your password';
                      if (text != _passwordController.text.trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  AppPrimaryButton(
                    label: 'Update Password',
                    onPressed: _updatePassword,
                    isLoading: _controller.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

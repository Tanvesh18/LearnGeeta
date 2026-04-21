import 'package:flutter/material.dart';

import '../core/app_dependencies.dart';
import '../core/widgets/app_gradient_scaffold.dart';
import '../core/utils/password_utils.dart';
import '../core/widgets/app_primary_button.dart';
import '../core/widgets/app_text_input.dart';
import '../core/widgets/auth_card.dart';
import '../core/widgets/password_feedback.dart';
import 'auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted || !success) return;

    if (_controller.signUpNeedsConfirmation) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Check your email to confirm.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;

    return AppGradientScaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _passwordController]),
        builder: (context, _) {
          return AuthCard(
            title: 'Join LearnGeeta',
            subtitle: 'Begin your journey with the Gita',
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextInput(
                    controller: _nameController,
                    label: 'Full Name',
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Please enter your email';
                      if (!text.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signup(),
                    validator: (value) => PasswordUtils.validate(
                      value?.trim() ?? '',
                      email: _emailController.text.trim(),
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
                    label: 'Create Account',
                    onPressed: _signup,
                    isLoading: _controller.isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Already have an account? Login'),
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

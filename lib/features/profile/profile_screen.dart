import 'package:flutter/material.dart';

import '../../core/app_dependencies.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/app_gradient_scaffold.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_input.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  late final ProfileController _controller;
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(
      profileRepository: AppDependencies.profileRepository,
      progressRepository: AppDependencies.progressRepository,
      authRepository: AppDependencies.authRepository,
    )..addListener(_syncFromController);
    _controller.load();
  }

  void _syncFromController() {
    final profile = _controller.profile;
    if (profile == null) return;
    if (_nameController.text != profile.fullName) {
      _nameController.text = profile.fullName;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncFromController)
      ..dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final success = await _controller.save(
      fullName: _nameController.text.trim(),
      language: _controller.profile?.language ?? 'English',
    );
    if (!mounted) return;
    if (success) {
      _showSnack('Profile updated');
    }
  }

  Future<void> _logout() async {
    await _controller.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final error = _controller.errorMessage;
        if (error != null &&
            error != _lastShownError &&
            !_controller.isLoading) {
          _lastShownError = error;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showSnack(error);
            }
          });
        }

        if (_controller.isLoading) {
          return const AppGradientScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = _controller.profile;
        final progress = _controller.progress;

        return AppGradientScaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.saffron,
            foregroundColor: Colors.white,
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.saffron.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Your profile',
                              style: TextStyle(
                                color: AppColors.saffron,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.saffron.withValues(alpha: 
                              0.24,
                            ),
                            child: Text(
                              profile?.fullName.isNotEmpty == true
                                  ? profile!.fullName
                                        .trim()
                                        .characters
                                        .first
                                        .toUpperCase()
                                  : 'ॐ',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.saffron,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile?.fullName.isNotEmpty == true
                                ? profile!.fullName
                                : 'Your Name',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Grow your knowledge every day',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Chip(
                            backgroundColor: AppColors.saffron.withValues(alpha: 0.12),
                            label: Text(
                              'Level ${progress?.level ?? 1}',
                              style: const TextStyle(
                                color: AppColors.saffron,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            avatar: const Icon(
                              Icons.star,
                              color: AppColors.saffron,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _statsCard(
                      level: progress?.level ?? 1,
                      xp: progress?.xp ?? 0,
                    ),
                    const SizedBox(height: 20),
                    _editCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statsCard({required int level, required int xp}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statWithIcon(Icons.star, 'Level', level.toString()),
            _statWithIcon(Icons.flash_on, 'XP', xp.toString()),
          ],
        ),
      ),
    );
  }

  Widget _statWithIcon(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.saffron, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _editCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profile settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Update your display name and keep your profile current.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 18),
            AppTextInput(
              controller: _nameController,
              label: 'Full name',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Save changes',
              onPressed: _save,
              isLoading: _controller.isSaving,
            ),
          ],
        ),
      ),
    );
  }
}

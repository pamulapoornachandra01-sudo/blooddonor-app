import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../rbac/models/app_role.dart';
import '../providers/local_auth_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  AppRole? _selectedRole;
  bool _isLoading = false;

  Future<void> _continue() async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);
    await ref.read(localAuthStateProvider.notifier).updateRole(_selectedRole!);
    setState(() => _isLoading = false);

    if (mounted) {
      context.go(AppRoutes.verificationPending);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text('I want to', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              _RoleCard(
                icon: Icons.bloodtype,
                title: 'Donate Blood',
                description: 'Help save lives by donating blood',
                isSelected: _selectedRole == AppRole.donor,
                onTap: () => setState(() => _selectedRole = AppRole.donor),
              ),
              const SizedBox(height: AppSpacing.md),
              _RoleCard(
                icon: Icons.person_search,
                title: 'Request Blood',
                description: 'Post a request when you need blood',
                isSelected: _selectedRole == AppRole.receiver,
                onTap: () => setState(() => _selectedRole = AppRole.receiver),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedRole == null || _isLoading ? null : _continue,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Continue'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({required this.icon, required this.title, required this.description, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 32),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : null)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

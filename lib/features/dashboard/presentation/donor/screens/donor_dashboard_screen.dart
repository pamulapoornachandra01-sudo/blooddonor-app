import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../auth/presentation/providers/local_auth_provider.dart';
import 'package:go_router/go_router.dart';

class DonorDashboardScreen extends ConsumerWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(localAuthStateProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Dashboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AvailabilityToggle(user: user),
              const SizedBox(height: AppSpacing.lg),
              _QuickActions(context: context),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  final dynamic user;

  const _AvailabilityToggle({this.user});

  @override
  Widget build(BuildContext context) {
    final isAvailable = user?.isAvailable ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isAvailable ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color: isAvailable ? AppColors.success : AppColors.warning,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isAvailable ? 'You are Available' : 'You are Unavailable',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isAvailable
                  ? 'Blood banks and receivers can see you as available for donation'
                  : 'Toggle to let others know you are available to donate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Switch(
              value: isAvailable,
              onChanged: (value) {},
              activeThumbColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final BuildContext context;

  const _QuickActions({required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ActionCard(
          icon: Icons.bloodtype,
          title: 'Browse Blood Requests',
          subtitle: 'Find people who need blood',
          color: AppColors.primary,
          onTap: () => context.go(AppRoutes.bloodRequests),
        ),
        const SizedBox(height: AppSpacing.md),
        _ActionCard(
          icon: Icons.history,
          title: 'My Donations',
          subtitle: 'View your donation history',
          color: AppColors.secondary,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

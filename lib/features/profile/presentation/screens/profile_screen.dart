import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/services/user_model.dart';
import '../../../auth/presentation/providers/local_auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(localAuthStateProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: AppSpacing.lg),
              _ProfileInfo(user: user),
              const SizedBox(height: AppSpacing.lg),
              _VerificationStatus(status: user?.verificationStatus ?? VerificationStatus.pending),
              const SizedBox(height: AppSpacing.lg),
              _MenuItems(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;

  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person, size: 50, color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          user?.name ?? 'User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          user?.phone ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            user?.role.displayName ?? '',
            style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final User? user;

  const _ProfileInfo({this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _InfoRow(label: 'Blood Type', value: user?.bloodType ?? 'Not set'),
            const Divider(),
            _InfoRow(label: 'Member Since', value: user?.createdAt.toString().split(' ')[0] ?? ''),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _VerificationStatus extends StatelessWidget {
  final VerificationStatus status;

  const _VerificationStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case VerificationStatus.verified:
        color = AppColors.success;
        icon = Icons.verified;
        label = 'Verified';
        break;
      case VerificationStatus.pending:
      case VerificationStatus.inReview:
        color = AppColors.warning;
        icon = Icons.pending;
        label = 'Pending Verification';
        break;
      case VerificationStatus.rejected:
        color = AppColors.error;
        icon = Icons.cancel;
        label = 'Verification Rejected';
        break;
    }

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItems extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await ref.read(localAuthStateProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }
}

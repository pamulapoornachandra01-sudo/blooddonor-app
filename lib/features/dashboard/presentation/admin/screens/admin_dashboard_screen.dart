import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../shared/services/local_admin_service.dart';
import '../../../../../shared/services/user_model.dart';

final adminUsersProvider = FutureProvider<List<User>>((ref) async {
  final service = ref.read(localAdminServiceProvider);
  final result = await service.getAllUsers();
  return result.fold((l) => [], (r) => r);
});

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(localAdminServiceProvider);
  final result = await service.getStats();
  return result.fold((l) => {}, (r) => r);
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              statsAsync.when(
                data: (stats) => _StatsGrid(stats: stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('User Management', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              usersAsync.when(
                data: (users) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) => _UserCard(user: users[index]),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _StatCard(title: 'Total Users', value: '${stats['totalUsers'] ?? 0}', icon: Icons.people, color: AppColors.secondary),
        _StatCard(title: 'Pending', value: '${stats['pendingVerifications'] ?? 0}', icon: Icons.pending, color: AppColors.warning),
        _StatCard(title: 'Verified', value: '${stats['verifiedUsers'] ?? 0}', icon: Icons.verified, color: AppColors.success),
        _StatCard(title: 'Donors', value: '${stats['donors'] ?? 0}', icon: Icons.bloodtype, color: AppColors.primary),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(title, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withValues(alpha: 0.1),
          child: Icon(Icons.person, color: _getStatusColor()),
        ),
        title: Row(
          children: [
            Text(user.name ?? user.phone),
            if (user.isBanned) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                child: const Text('BANNED', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ],
        ),
        subtitle: Text('${user.role.displayName} • ${user.verificationStatus.displayName}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'ban',
              child: Row(
                children: [
                  Icon(user.isBanned ? Icons.lock_open : Icons.block, size: 20),
                  const SizedBox(width: 8),
                  Text(user.isBanned ? 'Unban' : 'Ban'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            final service = ref.read(localAdminServiceProvider);
            if (value == 'ban') {
              if (user.isBanned) {
                await service.unbanUser(user.uid);
              } else {
                await service.banUser(user.uid);
              }
              ref.invalidate(adminUsersProvider);
              ref.invalidate(adminStatsProvider);
            }
          },
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (user.verificationStatus) {
      case VerificationStatus.verified:
        return AppColors.success;
      case VerificationStatus.pending:
      case VerificationStatus.inReview:
        return AppColors.warning;
      case VerificationStatus.rejected:
        return AppColors.error;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../verification/data/verification_provider.dart';
import '../../../../../shared/services/verification_model.dart';
import 'package:go_router/go_router.dart';

class VerifierDashboardScreen extends ConsumerWidget {
  const VerifierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingVerifs = ref.watch(pendingVerificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verifier Dashboard')),
      body: SafeArea(
        child: Column(
          children: [
            const _TodayCount(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Verification Queue', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: pendingVerifs.when(
                data: (verifs) => verifs.isEmpty
                    ? const _EmptyQueue()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: verifs.length,
                        itemBuilder: (context, index) {
                          return _VerificationCard(
                            verification: verifs[index],
                            onTap: () => context.push('/verification-review/${verifs[index].uid}'),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCount extends StatelessWidget {
  const _TodayCount();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 32),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reviewed Today', style: TextStyle(color: Colors.grey)),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: 0),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, _) {
                    return Text('$value', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: AppSpacing.md),
          Text('No pending verifications', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final Verification verification;
  final VoidCallback onTap;

  const _VerificationCard({required this.verification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.warning),
        ),
        title: Text('${verification.role.toUpperCase()} Verification'),
        subtitle: Text('Submitted: ${_formatDate(verification.submittedAt)}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

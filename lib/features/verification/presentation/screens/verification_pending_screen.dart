import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/services/user_model.dart';
import '../../../auth/presentation/providers/local_auth_provider.dart';

class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(localAuthStateProvider);
    final user = authState.valueOrNull;
    final status = user?.verificationStatus ?? VerificationStatus.pending;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              _StatusIcon(status: status),
              const SizedBox(height: AppSpacing.xl),
              _StatusTitle(status: status),
              const SizedBox(height: AppSpacing.md),
              _StatusDescription(status: status, role: user?.role.name ?? 'donor'),
              const Spacer(),
              if (status == VerificationStatus.pending || status == VerificationStatus.rejected)
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.verificationUpload),
                  child: Text(status == VerificationStatus.rejected ? 'Resubmit Documents' : 'Upload Documents'),
                ),
              if (status == VerificationStatus.verified)
                ElevatedButton(
                  onPressed: () {
                    final role = user?.role;
                    if (role?.name == 'donor') {
                      context.go(AppRoutes.donorDashboard);
                    } else if (role?.name == 'receiver') {
                      context.go(AppRoutes.receiverDashboard);
                    }
                  },
                  child: const Text('Continue'),
                ),
              if (status == VerificationStatus.inReview)
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Under Review'),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final VerificationStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (status) {
      case VerificationStatus.pending: icon = Icons.hourglass_empty; color = AppColors.pending; break;
      case VerificationStatus.inReview: icon = Icons.pending; color = AppColors.inReview; break;
      case VerificationStatus.verified: icon = Icons.check_circle; color = AppColors.verified; break;
      case VerificationStatus.rejected: icon = Icons.cancel; color = AppColors.rejected; break;
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, size: 80, color: color),
    );
  }
}

class _StatusTitle extends StatelessWidget {
  final VerificationStatus status;
  const _StatusTitle({required this.status});

  @override
  Widget build(BuildContext context) {
    String title;
    switch (status) {
      case VerificationStatus.pending: title = 'Verification Pending'; break;
      case VerificationStatus.inReview: title = 'In Review'; break;
      case VerificationStatus.verified: title = 'Verified!'; break;
      case VerificationStatus.rejected: title = 'Verification Rejected'; break;
    }
    return Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center);
  }
}

class _StatusDescription extends StatelessWidget {
  final VerificationStatus status;
  final String role;
  const _StatusDescription({required this.status, required this.role});

  @override
  Widget build(BuildContext context) {
    String description;
    final isDonor = role == 'donor';
    switch (status) {
      case VerificationStatus.pending:
        description = isDonor ? 'Upload your Government ID and a selfie.' : 'Upload ID, medical document, and selfie.';
        break;
      case VerificationStatus.inReview: description = 'Your documents are being reviewed (24-48 hours).'; break;
      case VerificationStatus.verified: description = 'Congratulations! Your account is verified.'; break;
      case VerificationStatus.rejected: description = 'Your verification was rejected. Please resubmit.'; break;
    }
    return Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center);
  }
}

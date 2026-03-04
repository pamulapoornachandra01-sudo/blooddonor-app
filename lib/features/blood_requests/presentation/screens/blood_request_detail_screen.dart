import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../blood_requests/data/blood_request_provider.dart';
import '../../../../shared/services/blood_request_model.dart';
import '../../../auth/presentation/providers/local_auth_provider.dart';

class BloodRequestDetailScreen extends ConsumerWidget {
  final String requestId;

  const BloodRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(bloodRequestDetailProvider(requestId));
    final authState = ref.watch(localAuthStateProvider);
    final currentUserId = authState.valueOrNull?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Request')),
      body: requestAsync.when(
        data: (request) => _RequestDetailContent(request: request, currentUserId: currentUserId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RequestDetailContent extends ConsumerWidget {
  final BloodRequest request;
  final String? currentUserId;

  const _RequestDetailContent({required this.request, this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = request.receiverId == currentUserId;
    final hasPledged = request.pledgedDonors.contains(currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderCard(request: request),
          const SizedBox(height: AppSpacing.lg),
          _InfoCard(request: request),
          const SizedBox(height: AppSpacing.lg),
          _DonorsCard(request: request),
          if (!isOwner && request.status != 'fulfilled') ...[
            const SizedBox(height: AppSpacing.lg),
            hasPledged
                ? OutlinedButton(
                    onPressed: () => _cancelPledge(context, ref),
                    child: const Text('Cancel Pledge'),
                  )
                : ElevatedButton(
                    onPressed: () => _pledge(context, ref),
                    child: const Text('Pledge to Donate'),
                  ),
          ],
          if (isOwner && request.status != 'fulfilled') ...[
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => _fulfill(context, ref),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: const Text('Mark as Fulfilled'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pledge(BuildContext context, WidgetRef ref) async {
    if (currentUserId == null) return;

    final actions = ref.read(bloodRequestActionsProvider);
    final result = await actions.pledgeDonation(request.id, currentUserId!);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: AppColors.error)),
      (r) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for pledging!'), backgroundColor: AppColors.success)),
    );
  }

  Future<void> _cancelPledge(BuildContext context, WidgetRef ref) async {
    if (currentUserId == null) return;

    final actions = ref.read(bloodRequestActionsProvider);
    final result = await actions.pledgeDonation(request.id, currentUserId!);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: AppColors.error)),
      (r) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pledge cancelled'))),
    );
  }

  Future<void> _fulfill(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(bloodRequestActionsProvider);
    final result = await actions.fulfillRequest(request.id);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: AppColors.error)),
      (r) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request fulfilled!'), backgroundColor: AppColors.success)),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final BloodRequest request;

  const _HeaderCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Text(request.bloodType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (request.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                const Spacer(),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('${request.unitsNeeded} units needed', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.xs),
            Text('${request.pledgedCount} of ${request.unitsNeeded} pledged', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: request.pledgedCount / request.unitsNeeded,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(request.pledgedCount >= request.unitsNeeded ? AppColors.success : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'posted': color = AppColors.warning; label = 'Posted'; break;
      case 'verified': color = AppColors.inReview; label = 'Verified'; break;
      case 'matched': color = AppColors.secondary; label = 'Matched'; break;
      case 'fulfilled': color = AppColors.success; label = 'Fulfilled'; break;
      default: color = Colors.grey; label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: color)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final BloodRequest request;

  const _InfoCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(icon: Icons.person, label: 'Patient', value: request.receiverName),
            const Divider(),
            _InfoRow(icon: Icons.location_on, label: 'Location', value: request.location),
            if (request.hospitalName != null) ...[
              const Divider(),
              _InfoRow(icon: Icons.local_hospital, label: 'Hospital', value: request.hospitalName!),
            ],
            if (request.contactPhone != null) ...[
              const Divider(),
              _InfoRow(icon: Icons.phone, label: 'Contact', value: request.contactPhone!),
            ],
            const Divider(),
            _InfoRow(icon: Icons.calendar_today, label: 'Posted', value: _formatDate(request.createdAt)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonorsCard extends StatelessWidget {
  final BloodRequest request;

  const _DonorsCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Pledged Donors', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (request.pledgedDonors.isEmpty)
              const Text('No donors have pledged yet', style: TextStyle(color: Colors.grey))
            else
              ...request.pledgedDonors.asMap().entries.map((entry) => ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.success.withValues(alpha: 0.1), child: const Icon(Icons.person, color: AppColors.success)),
                    title: Text('Donor ${entry.key + 1}'),
                    subtitle: const Text('Pledged to donate'),
                    trailing: const Icon(Icons.check_circle, color: AppColors.success),
                  )),
          ],
        ),
      ),
    );
  }
}

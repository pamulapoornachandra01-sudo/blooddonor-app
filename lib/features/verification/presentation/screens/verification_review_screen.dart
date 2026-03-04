import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../verification/data/verification_provider.dart';
import '../../../auth/presentation/providers/local_auth_provider.dart';

class VerificationReviewScreen extends ConsumerStatefulWidget {
  final String uid;

  const VerificationReviewScreen({super.key, required this.uid});

  @override
  ConsumerState<VerificationReviewScreen> createState() => _VerificationReviewScreenState();
}

class _VerificationReviewScreenState extends ConsumerState<VerificationReviewScreen> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    final authState = ref.read(localAuthStateProvider);
    final reviewerId = authState.valueOrNull?.uid ?? 'verifier_1';

    setState(() => _isLoading = true);
    final actions = ref.read(verificationActionsProvider);
    final result = await actions.approve(widget.uid, reviewerId);
    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: AppColors.error)),
      (verification) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification approved!'), backgroundColor: AppColors.success));
        context.pop();
      },
    );
  }

  Future<void> _reject() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a reason for rejection')));
      return;
    }

    final authState = ref.read(localAuthStateProvider);
    final reviewerId = authState.valueOrNull?.uid ?? 'verifier_1';

    setState(() => _isLoading = true);
    final actions = ref.read(verificationActionsProvider);
    final result = await actions.reject(widget.uid, _reasonController.text, reviewerId);
    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: AppColors.error)),
      (verification) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification rejected'), backgroundColor: AppColors.warning));
        context.pop();
      },
    );
  }

  Future<void> _requestInfo() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide what information is needed')));
      return;
    }

    setState(() => _isLoading = true);
    final actions = ref.read(verificationActionsProvider);
    final result = await actions.requestInfo(widget.uid, _reasonController.text);
    setState(() => _isLoading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: AppColors.error)),
      (verification) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Info requested'), backgroundColor: AppColors.secondary));
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Verification')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DocumentPreview(title: 'ID Front', icon: Icons.badge),
              const SizedBox(height: AppSpacing.md),
              _DocumentPreview(title: 'ID Back', icon: Icons.badge),
              const SizedBox(height: AppSpacing.md),
              _DocumentPreview(title: 'Selfie', icon: Icons.face),
              const SizedBox(height: AppSpacing.md),
              _DocumentPreview(title: 'Medical Document', icon: Icons.medical_services),
              const SizedBox(height: AppSpacing.xl),
              Text('Reason for rejection / Request more info:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Enter reason or additional info needed...'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _reject,
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _requestInfo,
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning, side: const BorderSide(color: AppColors.warning)),
                      child: const Text('Request Info'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _isLoading ? null : _approve,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Approve'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DocumentPreview({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const Text('(Document placeholder)', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../shared/services/local_verification_service.dart';
import '../../../auth/presentation/providers/local_auth_provider.dart';

final verificationUploadProvider = StateNotifierProvider<VerificationUploadNotifier, VerificationUploadState>((ref) {
  return VerificationUploadNotifier(ref);
});

class VerificationUploadState {
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;
  final String? medicalDocUrl;
  final bool isLoading;
  final String? error;

  const VerificationUploadState({
    this.idFrontUrl,
    this.idBackUrl,
    this.selfieUrl,
    this.medicalDocUrl,
    this.isLoading = false,
    this.error,
  });

  VerificationUploadState copyWith({
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
    String? medicalDocUrl,
    bool? isLoading,
    String? error,
  }) {
    return VerificationUploadState(
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      medicalDocUrl: medicalDocUrl ?? this.medicalDocUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VerificationUploadNotifier extends StateNotifier<VerificationUploadState> {
  final Ref _ref;
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  VerificationUploadNotifier(this._ref) : super(const VerificationUploadState());

  Future<void> _uploadImage(String docType, ImageSource source) async {
    try {
      state = state.copyWith(isLoading: true);

      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final uid = await _secureStorage.read(key: 'user_id');
      if (uid == null) {
        state = state.copyWith(isLoading: false, error: 'User not logged in');
        return;
      }

      // Save image locally instead of Firebase Storage
      final appDir = await getApplicationDocumentsDirectory();
      final verificationDir = Directory('${appDir.path}/verifications/$uid');
      if (!await verificationDir.exists()) {
        await verificationDir.create(recursive: true);
      }

      final localPath = '${verificationDir.path}/$docType.jpg';
      await File(image.path).copy(localPath);

      switch (docType) {
        case 'id_front':
          state = state.copyWith(idFrontUrl: localPath, isLoading: false);
          break;
        case 'id_back':
          state = state.copyWith(idBackUrl: localPath, isLoading: false);
          break;
        case 'selfie':
          state = state.copyWith(selfieUrl: localPath, isLoading: false);
          break;
        case 'medical_doc':
          state = state.copyWith(medicalDocUrl: localPath, isLoading: false);
          break;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uploadIdFront() => _uploadImage('id_front', ImageSource.gallery);
  Future<void> uploadIdBack() => _uploadImage('id_back', ImageSource.gallery);
  Future<void> uploadSelfie() => _uploadImage('selfie', ImageSource.camera);
  Future<void> uploadMedicalDoc() => _uploadImage('medical_doc', ImageSource.gallery);

  Future<void> submitVerification(String role) async {
    try {
      state = state.copyWith(isLoading: true);

      final uid = await _secureStorage.read(key: 'user_id');
      if (uid == null) {
        state = state.copyWith(isLoading: false, error: 'User not logged in');
        return;
      }

      // Use local verification service instead of Firestore
      final verificationService = _ref.read(localVerificationServiceProvider);
      await verificationService.submitVerification(
        uid: uid,
        role: role,
        idFrontUrl: state.idFrontUrl,
        idBackUrl: state.idBackUrl,
        selfieUrl: state.selfieUrl,
        medicalDocUrl: state.medicalDocUrl,
      );

      await _ref.read(localAuthStateProvider.notifier).refreshUser();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class VerificationUploadScreen extends ConsumerWidget {
  const VerificationUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(localAuthStateProvider);
    final user = authState.valueOrNull;
    final role = user?.role.name ?? 'donor';
    final state = ref.watch(verificationUploadProvider);
    final isDonor = role == 'donor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Please upload the following documents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              _DocumentCard(
                title: 'Government ID (Front)',
                icon: Icons.badge,
                imageUrl: state.idFrontUrl,
                onTap: () => ref.read(verificationUploadProvider.notifier).uploadIdFront(),
              ),
              const SizedBox(height: AppSpacing.md),
              _DocumentCard(
                title: 'Government ID (Back)',
                icon: Icons.badge,
                imageUrl: state.idBackUrl,
                onTap: () => ref.read(verificationUploadProvider.notifier).uploadIdBack(),
              ),
              if (!isDonor) ...[
                const SizedBox(height: AppSpacing.md),
                _DocumentCard(
                  title: 'Medical Document',
                  icon: Icons.medical_services,
                  imageUrl: state.medicalDocUrl,
                  onTap: () => ref.read(verificationUploadProvider.notifier).uploadMedicalDoc(),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _DocumentCard(
                title: 'Selfie',
                icon: Icons.face,
                imageUrl: state.selfieUrl,
                onTap: () => ref.read(verificationUploadProvider.notifier).uploadSelfie(),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: state.isLoading ? null : () async {
                  await ref.read(verificationUploadProvider.notifier).submitVerification(role);
                  if (context.mounted) {
                    context.pop();
                  }
                },
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit for Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.title,
    required this.icon,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: imageUrl != null ? AppColors.success.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                imageUrl != null ? Icons.check : icon,
                color: imageUrl != null ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    imageUrl != null ? 'Uploaded' : 'Tap to upload',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: imageUrl != null ? AppColors.success : Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.upload),
          ],
        ),
      ),
    );
  }
}

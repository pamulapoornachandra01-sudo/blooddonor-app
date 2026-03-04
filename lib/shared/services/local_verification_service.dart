import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import 'verification_model.dart';

class LocalVerificationService {
  final Map<String, Verification> _verifications = {};

  Future<Either<Failure, Verification>> submitVerification({
    required String uid,
    required String role,
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
    String? medicalDocUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (idFrontUrl == null || idBackUrl == null || selfieUrl == null) {
      return const Left(ValidationFailure('All required documents must be uploaded'));
    }

    if (role == 'receiver' && medicalDocUrl == null) {
      return const Left(ValidationFailure('Medical document is required for receivers'));
    }

    final verification = Verification(
      uid: uid,
      role: role,
      idFrontUrl: idFrontUrl,
      idBackUrl: idBackUrl,
      selfieUrl: selfieUrl,
      medicalDocUrl: medicalDocUrl,
      status: 'pending',
      submittedAt: DateTime.now(),
      canResubmit: true,
    );

    _verifications[uid] = verification;
    return Right(verification);
  }

  Future<Either<Failure, Verification>> getVerification(String uid) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final verification = _verifications[uid];
    if (verification == null) {
      return const Right(Verification(
        uid: '',
        role: 'donor',
        status: 'none',
      ));
    }
    return Right(verification);
  }

  Future<Either<Failure, List<Verification>>> getPendingVerifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final pending = _verifications.values
        .where((v) => v.status == 'pending')
        .toList()
      ..sort((a, b) => (a.submittedAt ?? DateTime.now()).compareTo(b.submittedAt ?? DateTime.now()));
    
    return Right(pending);
  }

  Future<Either<Failure, Verification>> approveVerification(String uid, String reviewerId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final verification = _verifications[uid];
    if (verification == null) {
      return const Left(NotFoundFailure('Verification not found'));
    }

    if (verification.reviewerId == reviewerId) {
      return const Left(ValidationFailure('You cannot approve your own verification'));
    }

    final updated = verification.copyWith(
      status: 'verified',
      reviewedAt: DateTime.now(),
      reviewerId: reviewerId,
      canResubmit: false,
    );

    _verifications[uid] = updated;
    return Right(updated);
  }

  Future<Either<Failure, Verification>> rejectVerification(String uid, String reason, String reviewerId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (reason.isEmpty) {
      return const Left(ValidationFailure('Rejection reason is required'));
    }

    final verification = _verifications[uid];
    if (verification == null) {
      return const Left(NotFoundFailure('Verification not found'));
    }

    final updated = verification.copyWith(
      status: 'rejected',
      reviewedAt: DateTime.now(),
      reviewerId: reviewerId,
      rejectionReason: reason,
      canResubmit: true,
    );

    _verifications[uid] = updated;
    return Right(updated);
  }

  Future<Either<Failure, Verification>> requestMoreInfo(String uid, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final verification = _verifications[uid];
    if (verification == null) {
      return const Left(NotFoundFailure('Verification not found'));
    }

    final updated = verification.copyWith(
      status: 'pending',
      rejectionReason: 'Additional info requested: $message',
    );

    _verifications[uid] = updated;
    return Right(updated);
  }
}

final localVerificationServiceProvider = Provider<LocalVerificationService>((ref) => LocalVerificationService());

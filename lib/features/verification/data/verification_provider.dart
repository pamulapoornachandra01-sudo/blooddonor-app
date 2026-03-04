import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../../shared/services/local_verification_service.dart';
import '../../../shared/services/verification_model.dart';

final localVerificationServiceProvider = Provider<LocalVerificationService>((ref) => LocalVerificationService());

final verificationProvider = StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  return VerificationNotifier(ref.read(localVerificationServiceProvider), ref);
});

class VerificationState {
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;
  final String? medicalDocUrl;
  final bool isLoading;
  final String? error;
  final bool submitted;

  const VerificationState({
    this.idFrontUrl,
    this.idBackUrl,
    this.selfieUrl,
    this.medicalDocUrl,
    this.isLoading = false,
    this.error,
    this.submitted = false,
  });

  VerificationState copyWith({String? idFrontUrl, String? idBackUrl, String? selfieUrl, String? medicalDocUrl, bool? isLoading, String? error, bool? submitted}) {
    return VerificationState(
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      medicalDocUrl: medicalDocUrl ?? this.medicalDocUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      submitted: submitted ?? this.submitted,
    );
  }
}

class VerificationNotifier extends StateNotifier<VerificationState> {
  final LocalVerificationService _verificationService;

  VerificationNotifier(this._verificationService, Ref ref) : super(const VerificationState());

  void setIdFront(String url) => state = state.copyWith(idFrontUrl: url);
  void setIdBack(String url) => state = state.copyWith(idBackUrl: url);
  void setSelfie(String url) => state = state.copyWith(selfieUrl: url);
  void setMedicalDoc(String url) => state = state.copyWith(medicalDocUrl: url);

  Future<void> submitVerification(String uid, String role) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _verificationService.submitVerification(
      uid: uid,
      role: role,
      idFrontUrl: state.idFrontUrl,
      idBackUrl: state.idBackUrl,
      selfieUrl: state.selfieUrl,
      medicalDocUrl: state.medicalDocUrl,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (verification) {
        state = state.copyWith(isLoading: false, submitted: true);
      },
    );
  }

  void reset() => state = const VerificationState();
}

final pendingVerificationsProvider = FutureProvider<List<Verification>>((ref) async {
  final service = ref.read(localVerificationServiceProvider);
  final result = await service.getPendingVerifications();
  return result.fold((l) => [], (r) => r);
});

final verificationActionsProvider = Provider<VerificationActions>((ref) {
  return VerificationActions(ref.read(localVerificationServiceProvider), ref);
});

class VerificationActions {
  final LocalVerificationService _service;
  final Ref _ref;

  VerificationActions(this._service, this._ref);

  Future<Either<Failure, Verification>> approve(String uid, String reviewerId) async {
    final result = await _service.approveVerification(uid, reviewerId);
    result.fold(
      (failure) => null,
      (verification) {
        _ref.invalidate(pendingVerificationsProvider);
      },
    );
    return result;
  }

  Future<Either<Failure, Verification>> reject(String uid, String reason, String reviewerId) async {
    final result = await _service.rejectVerification(uid, reason, reviewerId);
    result.fold(
      (failure) => null,
      (verification) {
        _ref.invalidate(pendingVerificationsProvider);
      },
    );
    return result;
  }

  Future<Either<Failure, Verification>> requestInfo(String uid, String message) async {
    final result = await _service.requestMoreInfo(uid, message);
    result.fold(
      (failure) => null,
      (verification) {
        _ref.invalidate(pendingVerificationsProvider);
      },
    );
    return result;
  }
}

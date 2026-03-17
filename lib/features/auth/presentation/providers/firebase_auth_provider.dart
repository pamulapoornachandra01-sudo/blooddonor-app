import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../rbac/models/app_role.dart';
import '../../../../shared/services/user_model.dart';
import '../../../../shared/services/firebase_auth_service.dart';
import '../../../../shared/services/firestore_service.dart';

final firebaseAuthNotifierProvider = StateNotifierProvider<FirebaseAuthNotifier, AsyncValue<User?>>((ref) {
  return FirebaseAuthNotifier(ref);
});

class FirebaseAuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  FirebaseAuthNotifier(this._ref) : super(const AsyncValue<User?>.loading()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    state = const AsyncValue<User?>.loading();
    final authService = _ref.read(firebaseAuthServiceProvider);
    final result = await authService.getCurrentUser();
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> sendOTP(String phone) async {
    final authService = _ref.read(firebaseAuthServiceProvider);
    await authService.sendOTP(phone);
  }

  Future<void> verifyOTP(String otp) async {
    state = const AsyncValue<User?>.loading();
    final authService = _ref.read(firebaseAuthServiceProvider);
    final result = await authService.verifyOTP(otp);
    
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) async {
        // Save user to Firestore
        final firestoreService = _ref.read(firestoreServiceProvider);
        await firestoreService.createUser(user);
        state = AsyncValue<User?>.data(user);
      },
    );
  }

  Future<void> register(String phone, AppRole role) async {
    // Handled by sendOTP + verifyOTP
  }

  Future<void> login(String phone) async {
    // Handled by sendOTP + verifyOTP
  }

  Future<void> updateRole(AppRole role) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(role: role);
    final firestoreService = _ref.read(firestoreServiceProvider);
    final result = await firestoreService.updateUser(updatedUser);
    
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> updateProfile({String? name, String? bloodType, bool? isAvailable}) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: name,
      bloodType: bloodType,
      isAvailable: isAvailable,
    );
    final firestoreService = _ref.read(firestoreServiceProvider);
    final result = await firestoreService.updateUser(updatedUser);
    
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> updateVerificationStatus(VerificationStatus status) async {
    final currentUser = state.valueOrNull;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(verificationStatus: status);
    final firestoreService = _ref.read(firestoreServiceProvider);
    final result = await firestoreService.updateUser(updatedUser);
    
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> signOut() async {
    final authService = _ref.read(firebaseAuthServiceProvider);
    await authService.signOut();
    state = const AsyncValue<User?>.data(null);
  }

  Future<void> refreshUser() async {
    await _checkAuthState();
  }
}

final phoneVerificationIdProvider = StateProvider<String?>((ref) => null);
final otpSentProvider = StateProvider<bool>((ref) => false);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../rbac/models/app_role.dart';
import '../../../../shared/services/user_model.dart';
import '../../../../shared/services/local_user_service.dart';

final localAuthServiceProvider = Provider<LocalUserService>((ref) => LocalUserService());

final localAuthStateProvider = StateNotifierProvider<LocalAuthNotifier, AsyncValue<User?>>((ref) {
  return LocalAuthNotifier(ref.read(localAuthServiceProvider));
});

class LocalAuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final LocalUserService _userService;

  LocalAuthNotifier(this._userService) : super(const AsyncValue<User?>.loading()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    state = const AsyncValue<User?>.loading();
    final result = await _userService.getCurrentUser();
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> register(String phone, AppRole role) async {
    state = const AsyncValue<User?>.loading();
    final result = await _userService.register(phone, role);
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> login(String phone) async {
    state = const AsyncValue<User?>.loading();
    final result = await _userService.login(phone);
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> updateRole(AppRole role) async {
    final result = await _userService.updateRole(role);
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> updateProfile({String? name, String? bloodType, bool? isAvailable}) async {
    final result = await _userService.updateProfile(
      name: name,
      bloodType: bloodType,
      isAvailable: isAvailable,
    );
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> updateVerificationStatus(VerificationStatus status) async {
    final result = await _userService.updateVerificationStatus(status);
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }

  Future<void> signOut() async {
    await _userService.logout();
    state = const AsyncValue<User?>.data(null);
  }

  Future<void> refreshUser() async {
    final result = await _userService.getCurrentUser();
    result.fold(
      (failure) => state = AsyncValue<User?>.error(failure, StackTrace.current),
      (user) => state = AsyncValue<User?>.data(user),
    );
  }
}

final phoneVerificationIdProvider = StateProvider<String?>((ref) => null);
final otpSentProvider = StateProvider<bool>((ref) => false);

// This file is deprecated. Use local_auth_provider.dart instead.
// Kept for reference only - all Firebase auth has been replaced with local storage.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/user_model.dart';
import '../../../../shared/services/local_user_service.dart';

// Re-export the local auth provider for backwards compatibility
final authServiceProvider = Provider<LocalUserService>((ref) => LocalUserService());

final authStateProvider = StateNotifierProvider<_DeprecatedAuthNotifier, AsyncValue<User?>>((ref) {
  return _DeprecatedAuthNotifier();
});

class _DeprecatedAuthNotifier extends StateNotifier<AsyncValue<User?>> {
  _DeprecatedAuthNotifier() : super(const AsyncValue<User?>.data(null));
}

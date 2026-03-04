// This file is deprecated. Use LocalUserService instead.
// Kept for reference only - all Firebase auth has been replaced with local storage.

import 'package:fpdart/fpdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/errors/failures.dart';
import '../../../rbac/models/app_role.dart';
import '../../../shared/services/user_model.dart';

/// Deprecated: Use LocalUserService from shared/services/local_user_service.dart
class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _userIdKey = 'user_id';

  Future<Either<Failure, String>> signInWithPhone(String phone) async {
    // No Firebase - just return a mock verification ID
    return const Right('local_verification');
  }

  Future<Either<Failure, User>> verifyOTP(String verificationId, String otp) async {
    return const Left(AuthFailure('Firebase auth removed - use local auth'));
  }

  Future<Either<Failure, User>> registerWithPhone(String phone, AppRole role) async {
    return const Left(AuthFailure('Firebase auth removed - use local auth'));
  }

  Future<Either<Failure, User?>> getCurrentUser() async {
    return const Right(null);
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: 'verification_id');
  }

  Future<Either<Failure, User>> updateUserRole(AppRole role) async {
    return const Left(AuthFailure('Firebase auth removed - use local auth'));
  }
}

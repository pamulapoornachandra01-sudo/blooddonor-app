import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../rbac/models/app_role.dart';
import 'user_model.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  String? _verificationId;

  Future<Either<Failure, String>> sendOTP(String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          // Error is handled in the catch block
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return const Right('otp_sent');
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> verifyOTP(String otp) async {
    try {
      if (_verificationId == null) {
        return const Left(AuthFailure('Please request OTP first'));
      }

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        return const Left(AuthFailure('Failed to sign in'));
      }

      final user = await _getOrCreateFirestoreUser(firebaseUser);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> registerWithPhone(String phone, AppRole role) async {
    try {
      final existingUsers = await _auth.fetchSignInMethodsForEmail('$phone@blooddonate.com');
      
      if (existingUsers.isEmpty) {
        return const Left(AuthFailure('Please use phone verification to register'));
      }
      
      return const Left(AuthFailure('User already exists'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }
      
      final user = await _getOrCreateFirestoreUser(firebaseUser);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> updateUserRole(AppRole role) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Not logged in'));
      }

      final user = await _updateFirestoreUserRole(firebaseUser.uid, role);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    _verificationId = null;
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _getOrCreateFirestoreUser(firebaseUser);
    });
  }

  Future<User> _getOrCreateFirestoreUser(firebase_auth.User firebaseUser) async {
    final now = DateTime.now();
    return User(
      uid: firebaseUser.uid,
      phone: firebaseUser.phoneNumber ?? '',
      role: AppRole.donor,
      verificationStatus: VerificationStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<User> _updateFirestoreUserRole(String uid, AppRole role) async {
    final now = DateTime.now();
    return User(
      uid: uid,
      phone: '',
      role: role,
      verificationStatus: VerificationStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authStateStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../rbac/models/app_role.dart';
import 'user_model.dart';

class LocalUserService {
  User? _currentUser;
  final Map<String, User> _users = {};

  Future<Either<Failure, User>> register(String phone, AppRole role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final existingUser = _users.values.where((u) => u.phone == phone).firstOrNull;
    if (existingUser != null) {
      _currentUser = existingUser;
      return Right(existingUser);
    }

    final now = DateTime.now();
    final user = User(
      uid: 'user_${now.millisecondsSinceEpoch}',
      phone: phone,
      role: role,
      verificationStatus: VerificationStatus.pending,
      createdAt: now,
      updatedAt: now,
      isAvailable: false,
      isBanned: false,
    );

    _users[user.uid] = user;
    _currentUser = user;
    return Right(user);
  }

  Future<Either<Failure, User>> login(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final existingUser = _users.values.where((u) => u.phone == phone).firstOrNull;
    if (existingUser != null) {
      _currentUser = existingUser;
      return Right(existingUser);
    }

    final now = DateTime.now();
    final user = User(
      uid: 'user_${now.millisecondsSinceEpoch}',
      phone: phone,
      role: AppRole.donor,
      verificationStatus: VerificationStatus.pending,
      createdAt: now,
      updatedAt: now,
      isAvailable: false,
      isBanned: false,
    );

    _users[user.uid] = user;
    _currentUser = user;
    return Right(user);
  }

  Future<Either<Failure, User?>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_currentUser == null) {
      return const Right(null);
    }
    return Right(_currentUser);
  }

  Future<Either<Failure, User>> updateRole(AppRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentUser == null) {
      return const Left(AuthFailure('Not logged in'));
    }

    final updated = _currentUser!.copyWith(role: role, updatedAt: DateTime.now());
    _users[updated.uid] = updated;
    _currentUser = updated;
    return Right(updated);
  }

  Future<Either<Failure, User>> updateProfile({String? name, String? bloodType, bool? isAvailable}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentUser == null) {
      return const Left(AuthFailure('Not logged in'));
    }

    final updated = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      bloodType: bloodType ?? _currentUser!.bloodType,
      isAvailable: isAvailable ?? _currentUser!.isAvailable,
      updatedAt: DateTime.now(),
    );
    _users[updated.uid] = updated;
    _currentUser = updated;
    return Right(updated);
  }

  Future<Either<Failure, User>> updateVerificationStatus(VerificationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentUser == null) {
      return const Left(AuthFailure('Not logged in'));
    }

    final updated = _currentUser!.copyWith(
      verificationStatus: status,
      updatedAt: DateTime.now(),
    );
    _users[updated.uid] = updated;
    _currentUser = updated;
    return Right(updated);
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  List<User> getAllUsers() => _users.values.toList();
}

final localUserServiceProvider = Provider<LocalUserService>((ref) => LocalUserService());

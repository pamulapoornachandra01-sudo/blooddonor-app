import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';
import '../../rbac/models/app_role.dart';
import 'user_model.dart';

class LocalAdminService {
  final Map<String, User> _users = {};

  void seedDemoUsers() {
    if (_users.isEmpty) {
      final now = DateTime.now();
      _users['user_1'] = User(
        uid: 'user_1',
        phone: '+919876543210',
        role: AppRole.donor,
        verificationStatus: VerificationStatus.verified,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        name: 'John Donor',
        bloodType: 'A+',
        isAvailable: true,
        isBanned: false,
      );
      _users['user_2'] = User(
        uid: 'user_2',
        phone: '+919876543211',
        role: AppRole.receiver,
        verificationStatus: VerificationStatus.pending,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
        name: 'Jane Receiver',
        bloodType: 'O-',
        isBanned: false,
      );
      _users['user_3'] = User(
        uid: 'user_3',
        phone: '+919876543212',
        role: AppRole.donor,
        verificationStatus: VerificationStatus.rejected,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
        name: 'Bob Smith',
        bloodType: 'B+',
        isBanned: false,
      );
      _users['user_4'] = User(
        uid: 'user_4',
        phone: '+919876543213',
        role: AppRole.verifier,
        verificationStatus: VerificationStatus.verified,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
        name: 'Alice Verifier',
        isBanned: false,
      );
      _users['user_5'] = User(
        uid: 'user_5',
        phone: '+919876543214',
        role: AppRole.admin,
        verificationStatus: VerificationStatus.verified,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
        name: 'Admin User',
        isBanned: false,
      );
    }
  }

  Future<Either<Failure, List<User>>> getAllUsers({String? role, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    var users = _users.values.toList();
    
    if (role != null && role.isNotEmpty) {
      users = users.where((u) => u.role.name == role).toList();
    }
    
    if (status != null && status.isNotEmpty) {
      users = users.where((u) => u.verificationStatus.name == status).toList();
    }
    
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Right(users);
  }

  Future<Either<Failure, User>> banUser(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final user = _users[uid];
    if (user == null) {
      return const Left(NotFoundFailure('User not found'));
    }
    
    final updated = user.copyWith(isBanned: true, updatedAt: DateTime.now());
    _users[uid] = updated;
    return Right(updated);
  }

  Future<Either<Failure, User>> unbanUser(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final user = _users[uid];
    if (user == null) {
      return const Left(NotFoundFailure('User not found'));
    }
    
    final updated = user.copyWith(isBanned: false, updatedAt: DateTime.now());
    _users[uid] = updated;
    return Right(updated);
  }

  Future<Either<Failure, Map<String, dynamic>>> getStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final totalUsers = _users.length;
    final pendingVerifs = _users.values.where((u) => u.verificationStatus == VerificationStatus.pending).length;
    final verifiedUsers = _users.values.where((u) => u.verificationStatus == VerificationStatus.verified).length;
    final bannedUsers = _users.values.where((u) => u.isBanned).length;
    final donors = _users.values.where((u) => u.role == AppRole.donor).length;
    final receivers = _users.values.where((u) => u.role == AppRole.receiver).length;
    
    return Right({
      'totalUsers': totalUsers,
      'pendingVerifications': pendingVerifs,
      'verifiedUsers': verifiedUsers,
      'bannedUsers': bannedUsers,
      'donors': donors,
      'receivers': receivers,
    });
  }

  List<User> get users => _users.values.toList();
}

final localAdminServiceProvider = Provider<LocalAdminService>((ref) {
  final service = LocalAdminService();
  service.seedDemoUsers();
  return service;
});

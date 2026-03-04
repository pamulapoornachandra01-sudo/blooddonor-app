import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donate/shared/services/local_user_service.dart';
import 'package:blood_donate/rbac/models/app_role.dart';

void main() {
  group('LocalUserService', () {
    late LocalUserService service;

    setUp(() {
      service = LocalUserService();
    });

    test('register creates new user', () async {
      final result = await service.register('+919876543210', AppRole.donor);
      
      result.fold(
        (failure) => fail('Expected success'),
        (user) {
          expect(user.phone, equals('+919876543210'));
          expect(user.role, equals(AppRole.donor));
          expect(user.isVerified, isFalse);
        },
      );
    });

    test('register creates same user on duplicate phone', () async {
      await service.register('+919876543210', AppRole.donor);
      final result = await service.register('+919876543210', AppRole.receiver);
      
      result.fold(
        (failure) => fail('Expected success'),
        (user) {
          expect(user.role, equals(AppRole.donor)); // First role preserved
        },
      );
    });

    test('updateRole updates user role', () async {
      await service.register('+919876543210', AppRole.donor);
      final result = await service.updateRole(AppRole.receiver);
      
      result.fold(
        (failure) => fail('Expected success'),
        (user) {
          expect(user.role, equals(AppRole.receiver));
        },
      );
    });

    test('updateProfile updates user fields', () async {
      await service.register('+919876543210', AppRole.donor);
      final result = await service.updateProfile(name: 'John Doe', bloodType: 'A+');
      
      result.fold(
        (failure) => fail('Expected success'),
        (user) {
          expect(user.name, equals('John Doe'));
          expect(user.bloodType, equals('A+'));
        },
      );
    });

    test('logout clears session', () async {
      await service.register('+919876543210', AppRole.donor);
      await service.logout();
      final result = await service.getCurrentUser();
      
      result.fold(
        (failure) => fail('Expected success'),
        (user) {
          expect(user, isNull);
        },
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donate/rbac/models/app_role.dart';
import 'package:blood_donate/rbac/models/app_permission.dart';
import 'package:blood_donate/rbac/role_permission_matrix.dart';

void main() {
  group('RolePermissionMatrix', () {
    test('superAdmin has all permissions', () {
      final permissions = RolePermissionMatrix.getPermissionsForRole(AppRole.superAdmin);
      expect(permissions.length, equals(AppPermission.values.length));
    });

    test('donor has correct permissions', () {
      final permissions = RolePermissionMatrix.getPermissionsForRole(AppRole.donor);
      expect(permissions.contains(AppPermission.viewBloodRequests), isTrue);
      expect(permissions.contains(AppPermission.pledgeDonation), isTrue);
      expect(permissions.contains(AppPermission.updateAvailability), isTrue);
      expect(permissions.contains(AppPermission.postBloodRequest), isFalse);
    });

    test('receiver has correct permissions', () {
      final permissions = RolePermissionMatrix.getPermissionsForRole(AppRole.receiver);
      expect(permissions.contains(AppPermission.postBloodRequest), isTrue);
      expect(permissions.contains(AppPermission.viewMyRequestStatus), isTrue);
      expect(permissions.contains(AppPermission.pledgeDonation), isFalse);
    });

    test('verifier has verification permissions', () {
      final permissions = RolePermissionMatrix.getPermissionsForRole(AppRole.verifier);
      expect(permissions.contains(AppPermission.viewVerificationQueue), isTrue);
      expect(permissions.contains(AppPermission.approveIdentity), isTrue);
      expect(permissions.contains(AppPermission.rejectIdentity), isTrue);
    });

    test('hasPermission returns correct value', () {
      expect(RolePermissionMatrix.hasPermission(AppRole.donor, AppPermission.pledgeDonation), isTrue);
      expect(RolePermissionMatrix.hasPermission(AppRole.donor, AppPermission.manageUsers), isFalse);
    });

    test('hospital has no permissions', () {
      final permissions = RolePermissionMatrix.getPermissionsForRole(AppRole.hospital);
      expect(permissions.isEmpty, isTrue);
    });
  });
}

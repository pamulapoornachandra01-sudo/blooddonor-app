import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/app_role.dart';
import 'models/app_permission.dart';
import 'role_permission_matrix.dart';

final rbacServiceProvider = Provider<RbacService>((ref) => RbacService());

class RbacService {
  bool hasPermission(AppRole role, AppPermission permission) {
    return RolePermissionMatrix.hasPermission(role, permission);
  }

  bool hasAnyPermission(AppRole role, Set<AppPermission> permissions) {
    return RolePermissionMatrix.hasAnyPermission(role, permissions);
  }

  bool hasAllPermissions(AppRole role, Set<AppPermission> permissions) {
    return RolePermissionMatrix.hasAllPermissions(role, permissions);
  }

  Set<AppPermission> getPermissionsForRole(AppRole role) {
    return RolePermissionMatrix.getPermissionsForRole(role);
  }

  bool isVerifiedUser(AppRole role, bool isVerified) {
    if (role == AppRole.superAdmin || role == AppRole.admin || role == AppRole.verifier) {
      return true;
    }
    return isVerified;
  }
}

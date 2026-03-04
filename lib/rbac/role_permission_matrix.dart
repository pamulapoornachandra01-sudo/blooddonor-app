import 'models/app_role.dart';
import 'models/app_permission.dart';

class RolePermissionMatrix {
  RolePermissionMatrix._();

  static const Map<AppRole, Set<AppPermission>> rolePermissions = {
    AppRole.superAdmin: {
      AppPermission.manageUsers,
      AppPermission.reviewVerifications,
      AppPermission.approveRejectUsers,
      AppPermission.viewAdminDashboard,
      AppPermission.viewVerificationQueue,
      AppPermission.approveIdentity,
      AppPermission.rejectIdentity,
      AppPermission.approveMedical,
      AppPermission.rejectMedical,
      AppPermission.requestMoreInfo,
      AppPermission.viewBloodRequests,
      AppPermission.pledgeDonation,
      AppPermission.updateAvailability,
      AppPermission.viewMyDonationHistory,
      AppPermission.postBloodRequest,
      AppPermission.viewMyRequestStatus,
      AppPermission.uploadMedicalProof,
      AppPermission.closeRequest,
    },
    AppRole.admin: {
      AppPermission.manageUsers,
      AppPermission.reviewVerifications,
      AppPermission.approveRejectUsers,
      AppPermission.viewAdminDashboard,
    },
    AppRole.verifier: {
      AppPermission.viewVerificationQueue,
      AppPermission.approveIdentity,
      AppPermission.rejectIdentity,
      AppPermission.approveMedical,
      AppPermission.rejectMedical,
      AppPermission.requestMoreInfo,
    },
    AppRole.donor: {
      AppPermission.viewBloodRequests,
      AppPermission.pledgeDonation,
      AppPermission.updateAvailability,
      AppPermission.viewMyDonationHistory,
    },
    AppRole.receiver: {
      AppPermission.postBloodRequest,
      AppPermission.viewMyRequestStatus,
      AppPermission.uploadMedicalProof,
      AppPermission.closeRequest,
    },
    AppRole.hospital: {},
  };

  static Set<AppPermission> getPermissionsForRole(AppRole role) {
    return rolePermissions[role] ?? {};
  }

  static bool hasPermission(AppRole role, AppPermission permission) {
    final permissions = rolePermissions[role];
    return permissions?.contains(permission) ?? false;
  }

  static bool hasAnyPermission(AppRole role, Set<AppPermission> permissions) {
    final rolePermissions = getPermissionsForRole(role);
    return permissions.any((p) => rolePermissions.contains(p));
  }

  static bool hasAllPermissions(AppRole role, Set<AppPermission> permissions) {
    final rolePermissions = getPermissionsForRole(role);
    return permissions.every((p) => rolePermissions.contains(p));
  }
}

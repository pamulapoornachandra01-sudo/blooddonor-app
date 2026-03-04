import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../rbac/models/app_role.dart';
import '../rbac/models/app_permission.dart';
import '../rbac/rbac_service.dart';

final permissionGuardProvider = Provider<PermissionGuard>((ref) => PermissionGuard(ref.read(rbacServiceProvider)));

class PermissionGuard {
  final RbacService _rbacService;

  PermissionGuard(this._rbacService);

  bool canAccess({
    required AppRole userRole,
    required bool isVerified,
    required Set<AppPermission> requiredPermissions,
  }) {
    if (userRole == AppRole.superAdmin) {
      return true;
    }

    if (requiredPermissions.isEmpty) {
      return true;
    }

    final isVerifiedUser = _rbacService.isVerifiedUser(userRole, isVerified);
    if (!isVerifiedUser) {
      return false;
    }

    return _rbacService.hasAnyPermission(userRole, requiredPermissions);
  }

  bool canAccessRoute({
    required AppRole userRole,
    required bool isVerified,
    required String routeName,
  }) {
    final permissions = _getRoutePermissions(routeName);
    return canAccess(
      userRole: userRole,
      isVerified: isVerified,
      requiredPermissions: permissions,
    );
  }

  Set<AppPermission> _getRoutePermissions(String routeName) {
    switch (routeName) {
      case 'admin_dashboard':
      case 'super_admin_dashboard':
        return {AppPermission.viewAdminDashboard};
      case 'verification_queue':
        return {AppPermission.viewVerificationQueue};
      case 'user_list':
        return {AppPermission.manageUsers};
      case 'blood_requests':
        return {AppPermission.viewBloodRequests};
      case 'pledge_donation':
        return {AppPermission.pledgeDonation};
      case 'update_availability':
        return {AppPermission.updateAvailability};
      case 'donation_history':
        return {AppPermission.viewMyDonationHistory};
      case 'post_blood_request':
        return {AppPermission.postBloodRequest};
      case 'my_requests':
        return {AppPermission.viewMyRequestStatus};
      default:
        return {};
    }
  }
}

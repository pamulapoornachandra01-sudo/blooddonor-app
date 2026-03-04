import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../rbac/models/app_role.dart';
import '../../features/auth/presentation/providers/local_auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/verification/presentation/screens/verification_pending_screen.dart';
import '../../features/verification/presentation/screens/verification_upload_screen.dart';
import '../../features/verification/presentation/screens/verification_review_screen.dart';
import '../../features/dashboard/presentation/admin/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/verifier/screens/verifier_dashboard_screen.dart';
import '../../features/dashboard/presentation/donor/screens/donor_dashboard_screen.dart';
import '../../features/dashboard/presentation/receiver/screens/receiver_dashboard_screen.dart';
import '../../features/blood_requests/presentation/screens/blood_requests_screen.dart';
import '../../features/blood_requests/presentation/screens/post_blood_request_screen.dart';
import '../../features/blood_requests/presentation/screens/my_requests_screen.dart';
import '../../features/blood_requests/presentation/screens/blood_request_detail_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(localAuthStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation == AppRoutes.login || 
                       state.matchedLocation == AppRoutes.register ||
                       state.matchedLocation == AppRoutes.roleSelection ||
                       state.matchedLocation == AppRoutes.splash;
      
      if (!isLoggedIn && !isOnAuth) {
        return AppRoutes.login;
      }
      
      if (isLoggedIn && isOnAuth) {
        final role = authState.valueOrNull?.role;
        final isVerified = authState.valueOrNull?.isVerified ?? false;
        
        if (!isVerified && role != AppRole.superAdmin && role != AppRole.admin && role != AppRole.verifier) {
          return AppRoutes.verificationPending;
        }
        
        return _getDashboardRoute(role);
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationPending,
        builder: (context, state) => const VerificationPendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationUpload,
        builder: (context, state) => const VerificationUploadScreen(),
      ),
      GoRoute(
        path: '/verification-review/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return VerificationReviewScreen(uid: uid);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.verifierDashboard,
            builder: (context, state) => const VerifierDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.donorDashboard,
            builder: (context, state) => const DonorDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.receiverDashboard,
            builder: (context, state) => const ReceiverDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.bloodRequests,
            builder: (context, state) => const BloodRequestsScreen(),
          ),
          GoRoute(
            path: '/blood-request/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return BloodRequestDetailScreen(requestId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.postBloodRequest,
            builder: (context, state) => const PostBloodRequestScreen(),
          ),
          GoRoute(
            path: AppRoutes.myRequests,
            builder: (context, state) => const MyRequestsScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.editProfile,
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

String _getDashboardRoute(AppRole? role) {
  switch (role) {
    case AppRole.superAdmin:
    case AppRole.admin:
      return AppRoutes.adminDashboard;
    case AppRole.verifier:
      return AppRoutes.verifierDashboard;
    case AppRole.donor:
      return AppRoutes.donorDashboard;
    case AppRole.receiver:
      return AppRoutes.receiverDashboard;
    default:
      return AppRoutes.login;
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failures.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  verificationApproved,
  verificationRejected,
  verificationReview,
  bloodRequestPledge,
  bloodRequestFulfilled,
  bloodRequestUrgent,
  general,
}

class LocalNotificationService {
  final Map<String, List<AppNotification>> _notifications = {};
  int _idCounter = 1;

  Future<Either<Failure, List<AppNotification>>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final notifications = _notifications[userId] ?? [];
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Right(notifications);
  }

  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final notifications = _notifications[userId] ?? [];
    final unread = notifications.where((n) => !n.isRead).length;
    return Right(unread);
  }

  Future<Either<Failure, void>> markAsRead(String userId, String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final notifications = _notifications[userId];
    if (notifications == null) {
      return const Right(null);
    }

    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }

    return const Right(null);
  }

  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final notifications = _notifications[userId];
    if (notifications != null) {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }

    return const Right(null);
  }

  Future<Either<Failure, void>> addNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    final notification = AppNotification(
      id: 'notif_${_idCounter++}',
      userId: userId,
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    );

    _notifications[userId] = [...(_notifications[userId] ?? []), notification];
    return const Right(null);
  }

  void seedDemoNotifications(String userId) {
    _notifications[userId] = [
      AppNotification(
        id: 'notif_1',
        userId: userId,
        title: 'Verification Approved',
        body: 'Your account has been verified successfully!',
        type: NotificationType.verificationApproved,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'notif_2',
        userId: userId,
        title: 'New Blood Request',
        body: 'Someone in your area needs A+ blood',
        type: NotificationType.bloodRequestUrgent,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif_3',
        userId: userId,
        title: 'Pledge Accepted',
        body: 'Your pledge to donate blood has been noted',
        type: NotificationType.bloodRequestPledge,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) => LocalNotificationService());

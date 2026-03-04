import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/local_notification_service.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) => LocalNotificationService());

final notificationsProvider = FutureProvider.family<List<AppNotification>, String>((ref, userId) async {
  final service = ref.read(localNotificationServiceProvider);
  service.seedDemoNotifications(userId);
  final result = await service.getNotifications(userId);
  return result.fold((l) => [], (r) => r);
});

final unreadCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.read(localNotificationServiceProvider);
  final result = await service.getUnreadCount(userId);
  return result.fold((l) => 0, (r) => r);
});

final notificationActionsProvider = Provider<NotificationActions>((ref) {
  return NotificationActions(ref.read(localNotificationServiceProvider));
});

class NotificationActions {
  final LocalNotificationService _service;

  NotificationActions(this._service);

  Future<void> markAsRead(String userId, String notificationId) async {
    await _service.markAsRead(userId, notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _service.markAllAsRead(userId);
  }
}

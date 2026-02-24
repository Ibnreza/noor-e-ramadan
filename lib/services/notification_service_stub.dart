/// Notification Service Stub for Web
/// Mock implementation that does nothing on web platform

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  /// Initialize notification service (no-op on web)
  Future<void> initialize() async {
    _isInitialized = true;
  }

  /// Request notification permissions (no-op on web)
  Future<bool> requestPermissions() async {
    return true;
  }

  /// Show immediate notification (no-op on web)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'general',
    String? payload,
  }) async {
    // No-op on web
  }

  /// Schedule notification (no-op on web)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = 'general',
    String? payload,
  }) async {
    // No-op on web
  }

  /// Schedule prayer time notification (no-op on web)
  Future<void> schedulePrayerTimeNotification({
    required String prayer,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    // No-op on web
  }

  /// Cancel notification (no-op on web)
  Future<void> cancelNotification(int id) async {
    // No-op on web
  }

  /// Cancel all notifications (no-op on web)
  Future<void> cancelAllNotifications() async {
    // No-op on web
  }
}

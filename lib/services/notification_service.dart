/// Notification Service
/// Handles all local notifications for prayer times, fasting, and reminders
/// Uses flutter_local_notifications package
/// No audio - only vibration as per requirements

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:vibration/vibration.dart';

import '../models/prayer_times_model.dart';
import '../models/user_settings_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false, // No sound as per requirements
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _isInitialized = true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Prayer time channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_times',
          'Prayer Times',
          description: 'Notifications for prayer times',
          importance: Importance.high,
          enableVibration: true,
          vibrationPattern: [0, 500, 200, 500],
          playSound: false,
        ),
      );

      // Pre-prayer reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'pre_prayer_reminders',
          'Pre-Prayer Reminders',
          description: 'Reminders before prayer times',
          importance: Importance.high,
          enableVibration: true,
          vibrationPattern: [0, 300, 100, 300],
          playSound: false,
        ),
      );

      // Fasting channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'fasting_notifications',
          'Fasting Notifications',
          description: 'Suhoor and Iftar notifications',
          importance: Importance.high,
          enableVibration: true,
          vibrationPattern: [0, 400, 200, 400, 200, 400],
          playSound: false,
        ),
      );

      // General channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'general',
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.defaultImportance,
          enableVibration: true,
          playSound: false,
        ),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screens
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
      // e.g., 'prayer:fajr', 'fasting:suhoor', etc.
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS permissions are requested during initialization
    return true;
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'general',
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: _getVibrationPattern(channelId),
      playSound: false,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);

    // Trigger vibration
    await _triggerVibration(channelId);
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = 'general',
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: _getVibrationPattern(channelId),
      playSound: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedule prayer time notification
  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required UserSettings settings,
  }) async {
    if (!settings.enablePrayerNotifications) return;

    final id = _getPrayerNotificationId(prayerName);
    final title = 'Time for $prayerName';
    final body = 'It is time to pray $prayerName. May Allah accept your prayer.';

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: prayerTime,
      channelId: 'prayer_times',
      payload: 'prayer:$prayerName',
    );
  }

  /// Schedule pre-prayer reminder
  Future<void> schedulePrePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required UserSettings settings,
  }) async {
    if (!settings.enablePrePrayerNotifications) return;

    final reminderTime = prayerTime.subtract(
      Duration(minutes: settings.prePrayerNotificationMinutes),
    );

    // Don't schedule if reminder time has passed
    if (reminderTime.isBefore(DateTime.now())) return;

    final id = _getPrePrayerNotificationId(prayerName);
    final title = '$prayerName in ${settings.prePrayerNotificationMinutes} minutes';
    final body = 'Prepare for $prayerName prayer. It\'s time to make wudu.';

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: reminderTime,
      channelId: 'pre_prayer_reminders',
      payload: 'pre_prayer:$prayerName',
    );
  }

  /// Schedule Suhoor notification
  Future<void> scheduleSuhoorNotification({
    required PrayerTimesModel prayerTimes,
    required UserSettings settings,
  }) async {
    if (!settings.enableSuhoorNotification) return;

    final suhoorTime = prayerTimes.imsak.subtract(const Duration(minutes: 10));

    // Don't schedule if time has passed
    if (suhoorTime.isBefore(DateTime.now())) return;

    final id = 100; // Fixed ID for Suhoor
    final title = settings.languageCode == 'bn' 
        ? 'সেহরির সময় শেষ হতে চলেছে'
        : 'Suhoor time ending soon';
    final body = settings.languageCode == 'bn'
        ? 'সেহরি খাওয়ার সময় ১০ মিনিট বাকি।'
        : '10 minutes left for Suhoor. Eat before Imsak time.';

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: suhoorTime,
      channelId: 'fasting_notifications',
      payload: 'fasting:suhoor',
    );
  }

  /// Schedule Iftar notification
  Future<void> scheduleIftarNotification({
    required PrayerTimesModel prayerTimes,
    required UserSettings settings,
  }) async {
    if (!settings.enableIftarNotification) return;

    final iftarTime = prayerTimes.maghrib;

    // Don't schedule if time has passed
    if (iftarTime.isBefore(DateTime.now())) return;

    final id = 101; // Fixed ID for Iftar
    final title = settings.languageCode == 'bn'
        ? 'ইফতারের সময়'
        : 'Iftar Time';
    final body = settings.languageCode == 'bn'
        ? 'ইফতারের সময় হয়েছে। আল্লাহ আপনার রোজা কবুল করুন।'
        : 'It is time for Iftar. May Allah accept your fast.';

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: iftarTime,
      channelId: 'fasting_notifications',
      payload: 'fasting:iftar',
    );
  }

  /// Schedule all daily notifications
  Future<void> scheduleDailyNotifications({
    required PrayerTimesModel prayerTimes,
    required UserSettings settings,
  }) async {
    // Cancel existing notifications first
    await cancelAllNotifications();

    // Schedule prayer notifications
    final prayers = [
      ('Fajr', prayerTimes.fajr),
      ('Dhuhr', prayerTimes.dhuhr),
      ('Asr', prayerTimes.asr),
      ('Maghrib', prayerTimes.maghrib),
      ('Isha', prayerTimes.isha),
    ];

    for (final (name, time) in prayers) {
      // Schedule main prayer notification
      await schedulePrayerNotification(
        prayerName: name,
        prayerTime: time,
        settings: settings,
      );

      // Schedule pre-prayer reminder
      await schedulePrePrayerNotification(
        prayerName: name,
        prayerTime: time,
        settings: settings,
      );
    }

    // Schedule fasting notifications
    await scheduleSuhoorNotification(
      prayerTimes: prayerTimes,
      settings: settings,
    );

    await scheduleIftarNotification(
      prayerTimes: prayerTimes,
      settings: settings,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel prayer notifications
  Future<void> cancelPrayerNotifications() async {
    final prayerIds = [1, 2, 3, 4, 5]; // Fajr, Dhuhr, Asr, Maghrib, Isha
    for (final id in prayerIds) {
      await _notifications.cancel(id);
      await _notifications.cancel(id + 10); // Pre-prayer IDs
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Trigger vibration pattern
  Future<void> _triggerVibration(String channelId) async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    switch (channelId) {
      case 'prayer_times':
        await Vibration.vibrate(pattern: [0, 500, 200, 500]);
        break;
      case 'pre_prayer_reminders':
        await Vibration.vibrate(pattern: [0, 300, 100, 300]);
        break;
      case 'fasting_notifications':
        await Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 400]);
        break;
      default:
        await Vibration.vibrate(duration: 300);
    }
  }

  /// Get channel name
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'prayer_times':
        return 'Prayer Times';
      case 'pre_prayer_reminders':
        return 'Pre-Prayer Reminders';
      case 'fasting_notifications':
        return 'Fasting Notifications';
      default:
        return 'General';
    }
  }

  /// Get channel description
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'prayer_times':
        return 'Notifications for prayer times';
      case 'pre_prayer_reminders':
        return 'Reminders before prayer times';
      case 'fasting_notifications':
        return 'Suhoor and Iftar notifications';
      default:
        return 'General app notifications';
    }
  }

  /// Get vibration pattern
  List<int> _getVibrationPattern(String channelId) {
    switch (channelId) {
      case 'prayer_times':
        return [0, 500, 200, 500];
      case 'pre_prayer_reminders':
        return [0, 300, 100, 300];
      case 'fasting_notifications':
        return [0, 400, 200, 400, 200, 400];
      default:
        return [0, 300];
    }
  }

  /// Get notification ID for prayer
  int _getPrayerNotificationId(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 1;
      case 'dhuhr':
        return 2;
      case 'asr':
        return 3;
      case 'maghrib':
        return 4;
      case 'isha':
        return 5;
      default:
        return 0;
    }
  }

  /// Get notification ID for pre-prayer reminder
  int _getPrePrayerNotificationId(String prayerName) {
    return _getPrayerNotificationId(prayerName) + 10;
  }
}

/// Notification payload parser
class NotificationPayload {
  final String type;
  final String value;

  NotificationPayload({
    required this.type,
    required this.value,
  });

  factory NotificationPayload.parse(String payload) {
    final parts = payload.split(':');
    if (parts.length == 2) {
      return NotificationPayload(type: parts[0], value: parts[1]);
    }
    return NotificationPayload(type: 'unknown', value: payload);
  }

  bool get isPrayer => type == 'prayer';
  bool get isPrePrayer => type == 'pre_prayer';
  bool get isFasting => type == 'fasting';

  String get prayerName => isPrayer ? value : '';
  String get fastingType => isFasting ? value : '';
}

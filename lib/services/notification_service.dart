import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);

    // Request permissions
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  static Future<void> scheduleMealNotifications() async {
    final canSchedule = await _canScheduleExactAlarms();
    if (!canSchedule) {
      // Fallback to inexact scheduling or skip
      print('Cannot schedule exact alarms, permission not granted');
      return;
    }

    // Breakfast at 8 AM
    await _scheduleNotification(
      id: 1,
      title: 'Breakfast Time!',
      body: 'Check out our breakfast recipe suggestions',
      hour: 8,
      minute: 0,
    );

    // Lunch at 2 PM
    await _scheduleNotification(
      id: 2,
      title: 'Lunch Time!',
      body: 'Discover delicious lunch recipes',
      hour: 14,
      minute: 0,
    );

    // Dinner at 7 PM
    await _scheduleNotification(
      id: 3,
      title: 'Dinner Time!',
      body: 'Explore our dinner recipe collection',
      hour: 19,
      minute: 0,
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      // Schedule for next day
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final canScheduleExact = await _canScheduleExactAlarms();

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_channel',
          'Meal Notifications',
          channelDescription: 'Notifications for meal times',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<bool> _canScheduleExactAlarms() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      return await androidPlugin.canScheduleExactNotifications() ?? false;
    }
    return true; // Assume true for non-Android platforms
  }
}
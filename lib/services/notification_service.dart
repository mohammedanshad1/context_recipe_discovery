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
  }

  static Future<void> scheduleMealNotifications() async {
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
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      // Schedule for next day
      scheduledTime.add(const Duration(days: 1));
    }

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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
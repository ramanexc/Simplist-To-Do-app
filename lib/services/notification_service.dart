import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  final Map<int, Timer> _windowsTimers = {};

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      await localNotifier.setup(
        appName: 'Simplist',
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
    } else {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }

    // Request permissions for Android 13+
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  Future<void> scheduleNotification(
      int id, String taskName, DateTime dueDate) async {
    
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'simplist_due_dates',
      'Due Dates',
      channelDescription: 'Notifications for task due dates',
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedule exact due time notification
    if (dueDate.isAfter(DateTime.now())) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        _windowsTimers[id]?.cancel();
        _windowsTimers[id] = Timer(dueDate.difference(DateTime.now()), () {
          LocalNotification(
            title: 'Simplist',
            body: '$taskName is due now',
          ).show();
        });
      } else {
        await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'Simplist',
            '$taskName is due now',
            tz.TZDateTime.from(dueDate, tz.local),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    }

    // Schedule 30 minutes before notification
    final thirtyMinsBefore = dueDate.subtract(const Duration(minutes: 30));
    if (thirtyMinsBefore.isAfter(DateTime.now())) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        _windowsTimers[id + 100000]?.cancel();
        _windowsTimers[id + 100000] = Timer(thirtyMinsBefore.difference(DateTime.now()), () {
          LocalNotification(
            title: 'Simplist',
            body: '$taskName is due in 30 minutes',
          ).show();
        });
      } else {
        await flutterLocalNotificationsPlugin.zonedSchedule(
            id + 100000, // Offset ID so it doesn't conflict with exact due time
            'Simplist',
            '$taskName is due in 30 minutes',
            tz.TZDateTime.from(thirtyMinsBefore, tz.local),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      _windowsTimers[id]?.cancel();
      _windowsTimers[id + 100000]?.cancel();
    } else {
      await flutterLocalNotificationsPlugin.cancel(id);
      await flutterLocalNotificationsPlugin.cancel(id + 100000);
    }
  }
}

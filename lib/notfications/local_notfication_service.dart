import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void notificationTapBackground(NotificationResponse details) {
  // Handle notification tap in background
}

class LocalNotficationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  static Future<void> requestPermission() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
  }

  static void showBasicNotification() async {
    AndroidNotificationDetails android = AndroidNotificationDetails(
      'id 1',
      'basic notification',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('sound.wav'.split('.').first),
    );

    NotificationDetails details = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(
      id: 1,

      title: 'Baisc Notification',
      body: 'body',
      notificationDetails: details,
      payload: "Payload Data",
    );
  }

  static void repeatedNotfication() async {
    AndroidNotificationDetails android = AndroidNotificationDetails(
      'id 1',
      'basic notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails details = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: 2,

      title: 'Repeated Notification',
      body: 'body',
      notificationDetails: details,
      payload: "Payload Data",
      repeatInterval: RepeatInterval.everyMinute,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  static Future<void> scheduledNotification() async {
    tz.initializeTimeZones();

    final android = AndroidNotificationDetails(
      'id_3',
      'Basic Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: android);
    log(tz.local.toString());

    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 10));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 3,
      title: 'Schedule Notification',
      body: 'Body',
      notificationDetails: details,
      payload: 'Payload Data',
      scheduledDate: scheduledDate,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  static void cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}

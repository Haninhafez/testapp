import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotficationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
   static StreamController<NotificationResponse> streamController =
      StreamController();

  static void onTap(NotificationResponse details) {
    log(details.id!.toString());
    log(details.payload!.toString());
    streamController.add(details);

  }

  static Future init() async {
    InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveBackgroundNotificationResponse: onTap,
      onDidReceiveNotificationResponse: onTap,
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

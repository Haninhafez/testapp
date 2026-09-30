// =====================================================
// الملف ده: Local Notification (إشعار محلي)
// =====================================================
// إشعار بيصنعه التطبيق نفسه على جهازك.
// مش محتاج Server ولا إنترنت.
// مثال: تذكير بموعد، أو منبّه.
//
// الحزمة المستخدمة: flutter_local_notifications
// (ضيفها في pubspec.yaml)
//
// وفي AndroidManifest.xml ضيف (لـ Android 13 وأحدث):
//   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
// =====================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:testapp/app_router.dart';
import 'package:testapp/main.dart';
import 'package:testapp/notfications/chatpage.dart';
import 'package:testapp/notfications/in_app_notification.dart';

// -----------------------------------------------------
// الـ Plugin: الكائن المسؤول عن كل حاجة في الإشعارات المحلية.
// بنعمله مرة واحدة ونستخدمه في كل التطبيق.
// -----------------------------------------------------
final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

// -----------------------------------------------------
// القناة (Channel) - مهمة في Android
// -----------------------------------------------------
// Android بيقسّم الإشعارات لقنوات، والمستخدم يقدر يتحكم في كل قناة
// من إعدادات الجهاز (يكتمها أو يغيّر صوتها).
// Importance.high معناها: الإشعار يطلع فوق الشاشة ويعمل صوت.
const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
  'main_channel', // ID: اسم داخلي ثابت (لازم يتطابق في كل مكان)
  'الإشعارات العامة', // الاسم اللي المستخدم يشوفه في الإعدادات
  description: 'كل إشعارات التطبيق', // وصف القناة
  importance: Importance.high, // درجة الأهمية
);

// -----------------------------------------------------
// 1) التهيئة (Initialize) - بنناديها مرة واحدة في main()
// -----------------------------------------------------
Future<void> initLocalNotifications() async {
  // إعدادات كل منصة:
  const initSettings = InitializationSettings(
    // أيقونة الإشعار في Android (هنا أيقونة التطبيق الافتراضية)
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    // إعدادات iOS (الافتراضية كفاية)
    iOS: DarwinInitializationSettings(),
  );

  await localNotifications.initialize(
    
    // الدالة دي بتشتغل لما المستخدم يضغط على الإشعار
    onDidReceiveNotificationResponse: (NotificationResponse response) {
  final payload = response.payload;
  if (payload == null || payload.isEmpty) return; // مفيش payload، متعملش حاجة

  // نفك النص ونحوله لـ Map
  final data = jsonDecode(payload) as Map<String, dynamic>;

  // نبص على قيمة screen ونقرر نفتح أنهي صفحة
  if (data['screen'] == 'chat') {
    router.push('/chat');
  } else {
    router.push('/home');
  }
}, settings: initSettings,
  );

  // الجزء الخاص بـ Android فقط:
  final androidPlugin =
      localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // إنشاء القناة اللي عرّفناها فوق
  await androidPlugin?.createNotificationChannel(mainChannel);

  // طلب الـ Permission من المستخدم (مطلوب في Android 13 وأحدث)
  await androidPlugin?.requestNotificationsPermission();
}

// -----------------------------------------------------
// 2) إظهار إشعار
// -----------------------------------------------------
Future<void> showLocalNotification({
  required String title, // العنوان
  required String body, // النص
  String? payload, // بيانات اختيارية بتترجع لما المستخدم يضغط على الإشعار
}) async {
  await localNotifications.show(
    // رقم الإشعار (ID). لو استخدمت نفس الرقم، الإشعار الجديد يستبدل القديم.
    // هنا بنستخدم الوقت الحالي عشان كل إشعار يبقى منفصل.
  id:  DateTime.now().millisecondsSinceEpoch ~/ 1000,
 title:    title,
 body: body,
  notificationDetails: NotificationDetails(
      // تفاصيل Android
      android: AndroidNotificationDetails(
        mainChannel.id, // لازم نفس ID القناة
        mainChannel.name,
        channelDescription: mainChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      // تفاصيل iOS
      iOS: const DarwinNotificationDetails(),
    ),
    payload: payload,
  );
}
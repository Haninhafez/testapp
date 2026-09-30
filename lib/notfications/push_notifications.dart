// =====================================================
// الملف ده: Push Notification (إشعار من الـ Server)
// =====================================================
// إشعار بيتبعت من Server عن طريق Firebase (FCM)،
// وبيوصلك حتى لو التطبيق مقفول.
//
// الحزم المستخدمة: firebase_core + firebase_messaging
//
// قبل ما تستخدمه لازم:
//   1) تعمل مشروع في Firebase Console.
//   2) تشغّل الأمر:  flutterfire configure
//      (بيعمل ملف firebase_options.dart تلقائي).
// =====================================================

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:testapp/firebase_options.dart';
import 'package:testapp/notfications/new.dart';
import 'in_app_notification.dart';


// -----------------------------------------------------
// 1) Background Handler
// -----------------------------------------------------
// بتشتغل لما توصل رسالة والتطبيق في الخلفية أو مقفول.
//
// قواعد مهمة:
//  - لازم تكون Top-level function (يعني برا أي Class).
//  - لازم @pragma عشان Flutter ما يمسحهاش في وضع Release.
//  - مفيش context ولا UI جواها.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // بتشتغل في Isolate منفصل (زي "غرفة" تانية)،
  // فلازم نعمل Initialize لـ Firebase تاني هنا.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('رسالة في الخلفية: ${message.notification?.title}');
  // ملحوظة: النظام بيعرض الإشعار لوحده في الخلفية،
  // الدالة دي بس لو عايز تعمل حاجة زيادة (تحفظ بيانات مثلاً).
}

// -----------------------------------------------------
// 2) التهيئة - بنناديها مرة واحدة في main() (بعد Firebase.initializeApp)
// -----------------------------------------------------
Future<void> initPushNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // ---- أ) طلب الـ Permission ----
  // يظهر للمستخدم سؤال "هل تسمح بالإشعارات؟"
  final settings = await messaging.requestPermission();
  debugPrint('حالة الـ Permission: ${settings.authorizationStatus}');

  // ---- ب) إعداد iOS ----
  // على iOS، خلّي الإشعار يظهر حتى لو التطبيق مفتوح.
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // ---- ج) الحصول على الـ Token ----
  // الـ Token = "عنوان" جهازك عند Firebase.
  // الـ Server بيحتاجه عشان يعرف يبعتلك إنت بالذات.
  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');
  // TODO: ابعت الـ token للـ Server بتاعك عشان يحفظه.

  // الـ Token ممكن يتغيّر مع الوقت، فنسمع للتغيير:
  messaging.onTokenRefresh.listen((newToken) {
    debugPrint('الـ Token اتغيّر: $newToken');
    // TODO: ابعت الـ token الجديد للـ Server.
  });

  // ---- د) التطبيق مفتوح (Foreground) ----
  // في Android، الإشعار مش بيظهر لوحده والتطبيق مفتوح،
  // فبنسمع للرسالة ونعرضها إحنا.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      // نعرضها كإشعار محلي (بيظهر في شريط الإشعارات)
      showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: jsonEncode(message.data), // البيانات الإضافية اللي بعتها الـ Server
      );
      // ونعرضها كمان كـ SnackBar (اختياري)
      showInAppSnackBar('${notification.title}: ${notification.body}');
    }
  });

  // ---- هـ) المستخدم ضغط على الإشعار والتطبيق كان في الخلفية ----
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('اتفتح التطبيق من إشعار، data = ${message.data}');
    // هنا تفتح صفحة معينة حسب message.data
  });

  // ---- و) المستخدم ضغط على الإشعار والتطبيق كان مقفول تماماً ----
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('التطبيق اشتغل من إشعار، data = ${initialMessage.data}');
    // هنا كمان تفتح الصفحة المناسبة
  }
}

// -----------------------------------------------------
// 3) Topics (اختياري)
// -----------------------------------------------------
// الـ Topic زي "قناة أخبار": أي حد مشترك فيها يوصله نفس الإشعار.
Future<void> subscribeToTopic(String topic) =>
    FirebaseMessaging.instance.subscribeToTopic(topic);

Future<void> unsubscribeFromTopic(String topic) =>
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
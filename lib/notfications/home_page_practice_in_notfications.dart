// =====================================================
// الملف ده: صفحة التجربة (Home Page)
// =====================================================
// فيها زر لكل نوع إشعار عشان تجرّبه بنفسك.
// =====================================================

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:testapp/notfications/email_sms_notfication.dart';
import 'package:testapp/notfications/new.dart';
import 'in_app_notification.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications Demo')),
      // ListView عشان الأزرار تتعمل Scroll لو الشاشة صغيرة
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- 1) Local Notification ----
          FilledButton(
            onPressed: () => showLocalNotification(
              title: 'تذكير',
              body: 'الاجتماع بعد 10 دقائق',
               payload: jsonEncode({'screen': 'chat'}),  // بيرجع لما تضغط على الإشعار
            ),
            child: const Text('Local Notification'),
          ),
          const SizedBox(height: 12),

          // ---- 2) In-App: SnackBar ----
          FilledButton(
            onPressed: () => showInAppSnackBar('تم حفظ التغييرات ✅'),
            child: const Text('In-App: SnackBar'),
          ),
          const SizedBox(height: 12),

          // ---- 3) In-App: Alert ----
          FilledButton(
            onPressed: () async {
              // await عشان نستنى اختيار المستخدم (موافق / إلغاء)
              final confirmed = await showInAppAlert(
                context,
                title: 'تنبيه',
                content: 'هل تريد الحذف؟',
              );
              showInAppSnackBar(confirmed ? 'تم الحذف' : 'تم الإلغاء');
            },
            child: const Text('In-App: Alert'),
          ),
          const SizedBox(height: 12),

          // ---- 4) Push: نجيب الـ Token عشان نجرّب من Firebase Console ----
          FilledButton(
            onPressed: () async {
              final token = await FirebaseMessaging.instance.getToken();
              debugPrint('FCM Token: $token'); // انسخه من الـ Console
              showInAppSnackBar('الـ Token اتطبع في الـ Console');
            },
            child: const Text('Push: اطبع الـ Token'),
          ),
          const SizedBox(height: 12),

          // ---- 5) Email (عن طريق Server) ----
          FilledButton(
            onPressed: () async {
              final ok = await requestEmailFromServer(
                to: 'user@example.com',
                subject: 'أهلاً بك',
                text: 'تم إنشاء حسابك',
              );
              showInAppSnackBar(ok ? 'تم طلب الإيميل' : 'فشل، تأكد من الـ Server');
            },
            child: const Text('Email (عن طريق Server)'),
          ),
          const SizedBox(height: 12),

          // ---- 6) SMS (عن طريق Server) ----
          FilledButton(
            onPressed: () async {
              final ok = await requestSmsFromServer(
                to: '+201000000000',
                body: 'رمز التحقق: 4821',
              );
              showInAppSnackBar(ok ? 'تم طلب الـ SMS' : 'فشل، تأكد من الـ Server');
            },
            child: const Text('SMS (عن طريق Server)'),
          ),
        ],
      ),
    );
  }
}
// =====================================================
// الملف ده: Email و SMS Notification
// =====================================================
// مهم جداً: التطبيق نفسه ما بيبعتش الإيميل ولا الـ SMS.
//
// الطريقة الصح:
//   تطبيق Flutter  ->  Server بتاعك  ->  SendGrid (إيميل) / Twilio (SMS)
//
// ليه؟ لأن SendGrid و Twilio بيحتاجوا مفاتيح سرية (API Keys).
// لو حطيتها جوا التطبيق، أي حد يقدر يفك التطبيق ويسرقها.
// فالمفاتيح تفضل على الـ Server، والتطبيق بس "بيطلب" منه.
//
// الحزمة المستخدمة: http (ضيفها في pubspec.yaml)
// =====================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

// غيّر الرابط ده لرابط الـ Server الحقيقي بتاعك
const String serverUrl = 'https://your-server.com';

// -----------------------------------------------------
// طلب إرسال Email
// -----------------------------------------------------
// بترجّع true لو الـ Server رد بنجاح.
Future<bool> requestEmailFromServer({
  required String to, // إيميل المستقبِل
  required String subject, // عنوان الرسالة
  required String text, // نص الرسالة
}) async {
  try {
    final response = await http.post(
      Uri.parse('$serverUrl/send-email'),
      // بنقول للـ Server إن اللي بنبعته JSON
      headers: {'Content-Type': 'application/json'},
      // نحوّل البيانات لـ JSON نص
      body: jsonEncode({'to': to, 'subject': subject, 'text': text}),
    );
    // كود 200 معناه نجاح
    return response.statusCode == 200;
  } catch (e) {
    // لو حصل خطأ (مفيش إنترنت مثلاً) نرجّع false بدل ما التطبيق يقع
    return false;
  }
}

// -----------------------------------------------------
// طلب إرسال SMS
// -----------------------------------------------------
Future<bool> requestSmsFromServer({
  required String to, // رقم التليفون بصيغة دولية (+201000000000)
  required String body, // نص الرسالة
}) async {
  try {
    final response = await http.post(
      Uri.parse('$serverUrl/send-sms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'to': to, 'body': body}),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
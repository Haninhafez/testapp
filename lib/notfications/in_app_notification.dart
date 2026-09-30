// =====================================================
// الملف ده: In-App Notification (إشعارات داخل التطبيق)
// =====================================================
// دي إشعارات بتظهر بس والتطبيق مفتوح قدامك.
// مش محتاجة Server ولا إنترنت ولا Permission.
// فيه نوعين هنا:
//   1) SnackBar : شريط صغير تحت الشاشة بيختفي لوحده.
//   2) Alert    : نافذة بتوقف المستخدم لحد ما يضغط زر.
// =====================================================

import 'package:flutter/material.dart';

// -----------------------------------------------------
// المفتاح (Key) اللي بيخلينا نعرض SnackBar من أي مكان
// -----------------------------------------------------
// ليه محتاجينه؟
// الطريقة العادية لعرض SnackBar محتاجة `context`،
// وفي أماكن كتير (زي جوا listener بتاع Firebase) مفيش context.
// المفتاح ده بيربط الكود بالـ MaterialApp من غير context.
//
// مهم: لازم نحطه في MaterialApp (في ملف main.dart) كده:
//   scaffoldMessengerKey: messengerKey
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

// -----------------------------------------------------
// 1) SnackBar
// -----------------------------------------------------
// بتاخد النص (message) وتعرضه تحت الشاشة لمدة 3 ثواني.
void showInAppSnackBar(String message) {
  // currentState = الـ ScaffoldMessenger المربوط بالمفتاح.
  // علامة ?. معناها: لو موجود نفّذ، ولو null (التطبيق لسه ما اترسمش) متعملش حاجة.
  messengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message), // النص اللي يظهر جوا الشريط
      duration: const Duration(seconds: 3), // مدة الظهور
    ),
  );
}

// -----------------------------------------------------
// 2) Alert Dialog
// -----------------------------------------------------
// الـ Dialog بيحتاج context لأنه بيتعرض فوق صفحة معينة.
// بترجّع true لو المستخدم ضغط "موافق"، و false لو ضغط "إلغاء".
Future<bool> showInAppAlert(
  BuildContext context, {
  required String title, // عنوان النافذة
  required String content, // النص جواها
}) async {
  // showDialog بتعرض النافذة وبتستنى المستخدم يقفلها.
  // النتيجة اللي بنحطها في Navigator.pop هي اللي بترجع هنا.
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        // زر الإلغاء: يقفل النافذة ويرجّع false
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('إلغاء'),
        ),
        // زر الموافقة: يقفل النافذة ويرجّع true
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('موافق'),
        ),
      ],
    ),
  );

  // لو المستخدم ضغط بره النافذة، result بتبقى null، فنعتبرها false.
  return result ?? false;
}
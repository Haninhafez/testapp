import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testapp/app_router.dart';
import 'package:testapp/firebase_options.dart';
import 'package:testapp/notfications/in_app_notification.dart';
import 'package:testapp/notfications/local_notfication_service.dart';
import 'package:testapp/notfications/new.dart';
import 'package:testapp/notfications/notfication_detealisl.dart';
import 'package:testapp/notfications/push_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotficationService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await LocalNotficationService.requestPermission();
  await initPushNotifications();
  await initLocalNotifications();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    // controller.repeat(reverse: true);
    listenToStream();
    super.initState();
  }

  void listenToStream() {
    LocalNotficationService.streamController.stream.listen((
      notificationResponse,
    ) {
      log(notificationResponse.id!.toString());
      log(notificationResponse.payload!.toString());
      //logic to get product from database.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              NotificationDetailsScreen(response: notificationResponse),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scaffoldMessengerKey: messengerKey,
     
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          SizedBox(width: double.infinity),
          ListTile(
            onTap: () => LocalNotficationService.showBasicNotification(),
            leading: const Icon(Icons.notifications),
            title: const Text('Basic Notification'),
            subtitle: const Text('with custom sound'),
            trailing: IconButton(
              onPressed: () => LocalNotficationService.cancelNotification(1),
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
          ),
          ListTile(
            onTap: () => LocalNotficationService.repeatedNotfication(),
            leading: const Icon(Icons.notifications),
            title: const Text('Repeated Notification'),
            subtitle: const Text('with custom sound'),
            trailing: IconButton(
              onPressed: () => LocalNotficationService.cancelNotification(2),
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
          ),

          ListTile(
            onTap: () => LocalNotficationService.scheduledNotification(),
            leading: const Icon(Icons.notifications),
            title: const Text('Schudeled Notification'),
            subtitle: const Text('with custom sound'),
            trailing: IconButton(
              onPressed: () => LocalNotficationService.cancelNotification(3),
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
          ),

          GestureDetector(
            onTap: () => LocalNotficationService.flutterLocalNotificationsPlugin
                .cancelAll(),
            child: Container(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text("Cancel All"),
            ),
          ),
          SizedBox(height: 100),

          GestureDetector(
            onTap: () => context.push('product/1'),
            child: Container(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Text("Go to product"),
            ),
          ),
        ],
      ),
    );
  }
}

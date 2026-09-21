import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testapp/firebase_options.dart';
import 'package:testapp/notfications/local_notfication_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotficationService.init();

  await LocalNotficationService.requestPermission();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
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
              onTap: () => LocalNotficationService
                  .flutterLocalNotificationsPlugin
                  .cancelAll(),
              child: Container(
                decoration: BoxDecoration(color: Colors.blueGrey),
                child: Text("Cancel All"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

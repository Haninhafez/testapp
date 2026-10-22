import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

class MemoryLeaksPage extends StatefulWidget {
  const MemoryLeaksPage({super.key});

  @override
  State<MemoryLeaksPage> createState() => _MemoryLeaksPageState();
}

class _MemoryLeaksPageState extends State<MemoryLeaksPage> {
  TextEditingController? controller;
  Timer? timer;
  int seconds = 0;
  StreamSubscription? subscription;
  @override
  void initState() {
    controller = TextEditingController();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
    subscription = Stream.periodic(const Duration(seconds: 1)).listen((event) {
      log('Memory leaks detected $event');
    });
    super.initState();
  }

  dispose() {
    controller?.dispose();
    timer?.cancel();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Memory Leaks Page')),
      appBar: AppBar(title: const Text('Memory Leaks Page')),
      body: Center(
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Name'),
            ),

            Text('Seconds: $seconds'),
          ],
        ),
      ),
    );
  }
}

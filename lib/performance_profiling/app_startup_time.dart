import 'dart:developer';

import 'package:flutter/material.dart';

class AppStartupTime extends StatefulWidget {
  const AppStartupTime({super.key});

  @override
  State<AppStartupTime> createState() => _AppStartupTimeState();
}

class _AppStartupTimeState extends State<AppStartupTime> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      log('App startup time: ${timeStamp.inMilliseconds} ms');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Startup Time')),
      body: const Center(child: Text('App startup time')),
    );
  }
}

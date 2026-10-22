import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

int heavyWork(int n) {
  int sum = 0;
  for (int i = 0; i < n; i++) {
    sum += i;
  }
  return sum;
}

class IsolateComputePage extends StatelessWidget {
  const IsolateComputePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isolate Compute Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final sw = Stopwatch()..start();
                final result = heavyWork(500000000);
                log('UI Thread: $result in ${sw.elapsedMilliseconds} ms');
              },
              child: const Text('Run on UI Thread'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final sw = Stopwatch()..start();
                final result = await compute(heavyWork, 500000000);
                log('compute: $result in ${sw.elapsedMilliseconds} ms');
              },
              child: const Text('Run with compute'),
            ),
          ],
        ),
      ),
    );
  }
}

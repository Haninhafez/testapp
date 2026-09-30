import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DeepLinkScreen extends StatelessWidget {
  const DeepLinkScreen({super.key, required this.id});
  final String id;

  void shareLink() async {
    print(
      ' ===========================deep link id is $id =========================',
    );
    final link = 'https://myapp.com/product/$id';
    await Share.share(link);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Link')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Deep Link'),

            Image.network(
              'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
              width: 200,
              height: 200,
            ),
            Text(
              'I am a deep link',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () {
                shareLink();
              },
              child: const Text('Share Link'),
            ),
          ],
        ),
      ),
    );
  }
}

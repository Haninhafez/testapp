import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:testapp/core/widgets/toast_app.dart';

class ImageOptmizationPage extends StatelessWidget {
  ImageOptmizationPage({super.key});
  final List<String> imageUrls = List.generate(
    50,
    (index) => 'https://picsum.photos/3000/2000?random=$index',
  );

  void logImageCache(BuildContext context) {
    final cache = PaintingBinding.instance.imageCache;

    final cachedImages = cache.currentSize;
    final cacheMemoryMB = cache.currentSizeBytes / (1024 * 1024);
    final liveImages = cache.liveImageCount;
    final pendingImages = cache.pendingImageCount;

    AppToast.showInfo(
      context: context,
      message:
          'Cached images: $cachedImages\n'
          'Cache memory: ${cacheMemoryMB.toStringAsFixed(2)} MB\n'
          'Live images: $liveImages\n'
          'Pending images: $pendingImages',
    );

    log('Cached images: $cachedImages');
    log('Cache memory: ${cacheMemoryMB.toStringAsFixed(2)} MB');
    log('Live images: $liveImages');
    log('Pending images: $pendingImages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Image Caching'),
        actions: [
          IconButton(
            onPressed: () => logImageCache(context),
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Log image cache',
          ),
        ],
      ),
      body: ImageWithOptmization(imageUrls: imageUrls),
    );
  }
}

class ImageWithoutOptmization extends StatelessWidget {
  const ImageWithoutOptmization({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imageUrls.length,

      itemBuilder: (context, index) {
        return Image.network(
          imageUrls[index],
          fit: BoxFit.cover,
          cacheWidth: 120,
          cacheHeight: 120,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return const SizedBox(
              width: 60,
              height: 60,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image);
          },
        );
      },
    );
  }
}

class ImageWithOptmization extends StatelessWidget {
  const ImageWithOptmization({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: imageUrls[index],
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          memCacheWidth: 120, // نفس فكرة cacheWidth
          placeholder: (context, url) => const SizedBox(
            width: 60,
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
        );
      },
    );
  }
}

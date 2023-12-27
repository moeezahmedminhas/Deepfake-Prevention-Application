import 'package:flutter/material.dart';

class ShowNetworkImage extends StatelessWidget {
  final String imageUrl;

  const ShowNetworkImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image')),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Set it to false to disable panning
          boundaryMargin: const EdgeInsets.all(80),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            errorBuilder: (context, error, stackTrace) {
              return const Text('An error occurred while loading the image.');
            },
          ),
        ),
      ),
    );
  }
}

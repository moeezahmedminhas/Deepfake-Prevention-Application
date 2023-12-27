import 'package:deepfake_prevention_app/common/utils/utils.dart';
import 'package:deepfake_prevention_app/features/deepfake/controller/deepfake_prevention_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for clipboard functionality
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';

class ProcessedImageScreen extends ConsumerWidget {
  final String imageId;
  final String watermarkMsg;
  const ProcessedImageScreen(
      {super.key, required this.imageId, required this.watermarkMsg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl =
        'https://res.cloudinary.com/dxxdandwe/image/upload/v1702876185/$imageId.png';
    final deepfakeController = ref.read(deepfakeControllerProvider);

    final size = MediaQuery.of(context).size;

    void copyToClipboard() {
      Clipboard.setData(ClipboardData(text: watermarkMsg));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Watermark copied to clipboard')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Protected Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Copy or Screenshot the watermark given below",
              style: textStyle.copyWith(
                  fontSize: size.height * 0.02,
                  color: const Color.fromARGB(255, 110, 109, 109)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.05),
            GestureDetector(
              onLongPress: copyToClipboard,
              child: Text(
                watermarkMsg,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: size.height * 0.015,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.05),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                // File(imagePath),
                imageUrl,
                width: size.width * 0.9,
                height: size.height * 0.25,
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            ElevatedButton(
              onPressed: () async {
                await deepfakeController.downloadImage(
                    context: context,
                    imageUrl: imageUrl,
                    imageId: imageId,
                    watermark: watermarkMsg);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: secondaryColor),
              child: const Text("Download Image"),
            ),
          ],
        ),
      ),
    );
  }
}

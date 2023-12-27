import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/utils/utils.dart';
import '../../../models/deepfake_data.dart';

final deepfakeRepositoryProvider = Provider(
    (ref) => DeepfakeRepository(firebaseFirestore: FirebaseFirestore.instance));

class DeepfakeRepository {
  final FirebaseFirestore firebaseFirestore;

  DeepfakeRepository({required this.firebaseFirestore});
  Future<List<DeepfakeData>> fetchDeepfakeData() async {
    final snapshot = await firebaseFirestore
        .collection('users')
        .doc(currentUserUid)
        .collection('deepfakes')
        .get();

    return snapshot.docs
        .map((doc) => DeepfakeData.fromMap(doc.data()))
        .toList();
  }

  void saveDataToFireBase(
      {required BuildContext context,
      required String imageId,
      required String watermark}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('deepfakes')
          .doc(imageId)
          .set({'imageId': imageId, 'watermark': watermark});
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Deepfake Prevention')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Deepfake Prevention')),
      );
    }
  }

  Future<void> deleteDeepfakeData(
      BuildContext context, String documentId) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(currentUserUid)
          .collection('deepfakes')
          .doc(documentId)
          .delete();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deepfake deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  Future<void> downloadImage(
      {required BuildContext context,
      required String imageUrl,
      required String imageId,
      required String watermark}) async {
    var storageStatus = await Permission.storage.status;
    var photosStatus = await Permission.photos.status;
    var externalStorageStatus = await Permission.manageExternalStorage.status;

    var photosAddOnlyStatus = await Permission.photosAddOnly.status;
    var mediaLibraryStatus = await Permission.mediaLibrary.status;
    if (kDebugMode) {
      print(storageStatus.isGranted);
      print(photosStatus.isGranted);
      print(externalStorageStatus.isGranted);
      print(photosAddOnlyStatus.isGranted);
      print(mediaLibraryStatus.isGranted);
    }
    if (!photosStatus.isGranted) {
      photosStatus = await Permission.photos.request();
    }
    if (!externalStorageStatus.isGranted) {
      externalStorageStatus = await Permission.manageExternalStorage.request();
    }
    if (Platform.isIOS && !photosAddOnlyStatus.isGranted) {
      photosAddOnlyStatus = await Permission.photosAddOnly.request();
    }
    if (Platform.isIOS && !mediaLibraryStatus.isGranted) {
      mediaLibraryStatus = await Permission.mediaLibrary.request();
    }
    if (photosStatus.isGranted ||
        storageStatus.isGranted ||
        photosAddOnlyStatus.isGranted ||
        mediaLibraryStatus.isGranted) {
      final progressNotifier = ValueNotifier<String>('Downloading... 0%');
      final snackBar = SnackBar(
        content: ValueListenableBuilder<String>(
          valueListenable: progressNotifier,
          builder: (_, value, __) => Text(value),
        ),
        duration: const Duration(minutes: 5),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      try {
        await Dio().get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              int percentage = ((received / total) * 100).toInt();
              progressNotifier.value = 'Downloading... $percentage%';
            }
          },
        ).then((response) async {
          final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.data),
            name: imageId,
            isReturnImagePathOfIOS: true,
          );

          if (kDebugMode) {
            print(result);
          }
          progressNotifier.value = 'Download complete! Image saved to gallery.';
          await Future.delayed(const Duration(seconds: 2));
        });
      } catch (e) {
        progressNotifier.value = 'Error: $e';
        await Future.delayed(const Duration(seconds: 2));
      } finally {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          saveDataToFireBase(
              context: context, imageId: imageId, watermark: watermark);
        }
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  // Future<void> downloadImage(
  //     {required BuildContext context,
  //     required String imageUrl,
  //     required String imageId,
  //     required String watermark}) async {
  //   var status = await Permission.storage.status;
  //   var photosStatus = await Permission.photos.status;
  //   var externalStorageStatus = await Permission.manageExternalStorage.status;

  //   var photosAddOnlyStatus = await Permission.photosAddOnly.status;
  //   var mediaLibraryStatus = await Permission.mediaLibrary.status;
  //   if (kDebugMode) {
  //     print(status.isGranted);
  //     print(photosStatus.isGranted);
  //     print(externalStorageStatus.isGranted);
  //     print(photosAddOnlyStatus.isGranted);
  //     print(mediaLibraryStatus.isGranted);
  //   }
  //   if (!photosStatus.isGranted) {
  //     photosStatus = await Permission.photos.request();
  //   }
  //   if (!externalStorageStatus.isGranted) {
  //     externalStorageStatus = await Permission.manageExternalStorage.request();
  //   }
  //   if (Platform.isIOS && !photosAddOnlyStatus.isGranted) {
  //     photosAddOnlyStatus = await Permission.photosAddOnly.request();
  //   }
  //   if (Platform.isIOS && !mediaLibraryStatus.isGranted) {
  //     mediaLibraryStatus = await Permission.mediaLibrary.request();
  //   }
  //   if (photosStatus.isGranted ||
  //       photosAddOnlyStatus.isGranted ||
  //       mediaLibraryStatus.isGranted) {
  //     try {
  //       // Get the local path to store the image
  //       final directory = Platform.isAndroid
  //           ? await getDownloadsDirectory()
  //           : await getApplicationDocumentsDirectory();
  //       if (directory == null) {
  //         if (!context.mounted) return;
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //               content: Text('Applciation Directory Cannot be Accessed')),
  //         );
  //         return;
  //       }

  //       final taskId = await FlutterDownloader.enqueue(
  //         url: imageUrl,
  //         savedDir: directory.path,
  //         fileName: '$imageId.png',
  //         showNotification: true,
  //         openFileFromNotification: true,
  //       );
  //       if (kDebugMode) {
  //         print(taskId);
  //       }

  //       if (!context.mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Download started')),
  //       );
  //       saveDataToFireBase(
  //           context: context, imageId: imageId, watermark: watermark);
  //     } catch (e) {
  //       if (!context.mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: $e')),
  //       );
  //     }
  //   } else {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Storage permission denied')),
  //     );
  //   }
  // }
}

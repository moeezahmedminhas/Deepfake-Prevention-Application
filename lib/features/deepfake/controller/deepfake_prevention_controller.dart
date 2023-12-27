import 'package:deepfake_prevention_app/features/deepfake/repositories/deepfake_prevention_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/deepfake_data.dart';

final deepfakeControllerProvider = Provider((ref) {
  final deepfakeRepository = ref.watch(deepfakeRepositoryProvider);
  return DeepfakeController(deepfakeRepository: deepfakeRepository, ref: ref);
});

class DeepfakeController {
  final DeepfakeRepository deepfakeRepository;
  final ProviderRef ref;
  DeepfakeController({required this.deepfakeRepository, required this.ref});
  void saveDataToFireBase(
      {required BuildContext context,
      required String imageId,
      required String imageUrl,
      required String watermark}) async {
    ref.read(deepfakeRepositoryProvider).saveDataToFireBase(
        context: context, imageId: imageId, watermark: watermark);
  }

  Future<void> downloadImage(
      {required BuildContext context,
      required String imageUrl,
      required String imageId,
      required String watermark}) async {
    await ref.read(deepfakeRepositoryProvider).downloadImage(
        context: context,
        imageUrl: imageUrl,
        imageId: imageId,
        watermark: watermark);
  }

  Future<List<DeepfakeData>> fetchDeepfakeData() async {
    return await ref.read(deepfakeRepositoryProvider).fetchDeepfakeData();
  }

  Future<void> deleteDeepfakeData(
      BuildContext context, String documentId) async {
    await ref
        .read(deepfakeRepositoryProvider)
        .deleteDeepfakeData(context, documentId);
  }
}

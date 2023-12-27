class DeepfakeData {
  final String imageId;
  final String watermark;

  DeepfakeData({required this.imageId, required this.watermark});

  factory DeepfakeData.fromMap(Map<String, dynamic> data) {
    return DeepfakeData(
      imageId: data['imageId'],
      watermark: data['watermark'],
    );
  }
}

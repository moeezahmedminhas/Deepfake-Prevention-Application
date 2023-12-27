import 'package:deepfake_prevention_app/common/widgets/loader.dart';
import 'package:deepfake_prevention_app/features/deepfake/controller/deepfake_prevention_controller.dart';
import 'package:deepfake_prevention_app/features/deepfake/screens/processed_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/deepfake_data.dart';
import '../../chat/widgets/change_lock_chats_password.dart';

class DeepfakeDataScreen extends ConsumerStatefulWidget {
  const DeepfakeDataScreen({super.key});
  static const routeName = "deepfake-data-screen";
  @override
  ConsumerState<DeepfakeDataScreen> createState() => _DeepfakeDataScreenState();
}

class _DeepfakeDataScreenState extends ConsumerState<DeepfakeDataScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Protected Items"),
        actions: const [
          ChangeLockedItemsPassWidget(),
        ],
      ),
      body: FutureBuilder<List<DeepfakeData>>(
        future: ref.read(deepfakeControllerProvider).fetchDeepfakeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No deepfake data found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProcessedImageScreen(
                      imageId: data.imageId,
                      watermarkMsg: data.watermark,
                    ),
                  ));
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://res.cloudinary.com/dxxdandwe/image/upload/v1702876185/${data.imageId}.png'),
                  ),
                  title: Text(data.imageId),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref
                          .read(deepfakeControllerProvider)
                          .deleteDeepfakeData(context, data.imageId);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

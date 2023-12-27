import 'dart:io';
import 'package:deepfake_prevention_app/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../controller/auth_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  File? image;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty || name != "") {
      ref.read(authControllerProvider).saveUserDataToFirebase(
            context,
            name,
            image,
          );
      ref.read(authControllerProvider).addDevice();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Your Info"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                Stack(
                  children: [
                    image == null
                        ? const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                            ),
                            radius: 84,
                          )
                        : CircleAvatar(
                            backgroundImage: FileImage(
                              image!,
                            ),
                            radius: 84,
                          ),
                    Positioned(
                      bottom: 0,
                      left: 120,
                      child: CircleAvatar(
                        backgroundColor: primaryColor,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                Container(
                  // width: size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: nameController,
                    decoration: fieldStyle.copyWith(hintText: "Name"),
                    validator: (value) {
                      if (value == "" || value == null) {
                        return 'Please Write Your name';
                      }
                      return "";
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: CustomButton(onPressed: storeUserData, text: 'Done'),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: storeUserData,
                      icon: const Icon(
                        Icons.done,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

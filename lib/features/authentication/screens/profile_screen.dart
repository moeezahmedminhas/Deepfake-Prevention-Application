import 'dart:io';
import 'dart:ui';
import 'package:deepfake_prevention_app/common/widgets/custom_button.dart';
import 'package:deepfake_prevention_app/features/authentication/screens/privacy_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../../../models/user_model.dart';
import '../controller/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = '/profile-screen';
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  bool? readReciepts;
  File? image;
  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider).getUserData().then((value) {
      nameController.text = value!.name;
      phoneController.text = value.phoneNumber;
      statusController.text = value.status;
    });
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final key = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Profile"),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      content: Text(
                        "Are you sure about logging out?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                        ),
                      ),
                      actions: [
                        TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        TextButton(
                            child: const Text('Logout'),
                            onPressed: () {
                              ref.read(authControllerProvider).logout(context);
                            }),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<UserModel>(
                stream: ref
                    .read(authControllerProvider)
                    .userDataById(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  return Center(
                    child: Form(
                      key: key,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                    sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(
                                  height: size.height * 0.24,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          snapshot.data!.profilePic,
                                        ),
                                        fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                              Stack(
                                children: [
                                  image == null
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            snapshot.data!.profilePic,
                                          ),
                                          radius: size.height * 0.11,
                                        )
                                      : CircleAvatar(
                                          backgroundImage: FileImage(
                                            image!,
                                          ),
                                          radius: size.height * 0.11,
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    left: size.width * 0.32,
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
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneController,
                    enabled: false,
                    style: const TextStyle(
                      color: secondaryTextColor,
                    ), // Set text color to black
                    decoration: fieldStyle.copyWith(
                        hintText: 'Phone',
                        fillColor: const Color.fromARGB(255, 236, 233, 233),
                        labelText: "Phone",
                        filled: true),
                    validator: (value) {
                      if (value == '' || value == null) {
                        return 'Name Is Required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(
                      color: secondaryTextColor,
                    ), // Set text color to black
                    decoration: fieldStyle.copyWith(
                      hintText: 'Name',
                      labelText: "Name",
                    ),
                    validator: (value) {
                      if (value == '' || value == null) {
                        return 'Name Is Required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  TextFormField(
                    controller: statusController,

                    style: const TextStyle(
                      color: secondaryTextColor,
                    ), // Set text color to black
                    decoration: fieldStyle.copyWith(
                        hintText: 'Status', labelText: "Status"),
                    validator: (value) {
                      if (value == '' || value == null) {
                        return 'Status Is Required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  RichText(
                    text: TextSpan(
                        text: 'Privacy Settings ',
                        style: const TextStyle(
                          color: accentColor,
                        ),
                        children: [
                          TextSpan(
                              text: 'Tap to edit',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                      context, PrivacySettingsScreen.routeName);
                                },
                              style: const TextStyle(
                                color: primaryColor,
                              ))
                        ]),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  CustomButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        ref
                            .read(authControllerProvider)
                            .updateUserDataToFirebase(
                                context,
                                nameController.text,
                                image,
                                statusController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Fill The Required Fields')));
                      }
                    },
                    text: "Save",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:deepfake_prevention_app/common/widgets/custom_button.dart';
// import 'package:deepfake_prevention_app/features/authentication/screens/privacy_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';

// import '../../../common/utils/colors.dart';
// import '../../../common/utils/utils.dart';
// import '../../../models/user_model.dart';
// import '../controller/auth_controller.dart';
// import 'package:http/http.dart' as http;

// Future<File> downloadImage(String imageUrl) async {
//   // Get the image data from the URL
//   final response = await http.get(Uri.parse(imageUrl));
//   if (response.statusCode == 200) {
//     // Find the correct local path for the image
//     final documentDirectory = await getApplicationDocumentsDirectory();

//     // Create a file in the path with a unique name
//     final file = File(
//         '${documentDirectory.path}/image_${DateTime.now().millisecondsSinceEpoch}.png');

//     // Write the image data to the file
//     file.writeAsBytesSync(response.bodyBytes);

//     return file;
//   } else {
//     throw Exception('Failed to download image');
//   }
// }

// Stream<UserModel> userData() {
//   return FirebaseFirestore.instance
//       .collection('users')
//       .doc(FirebaseAuth.instance.currentUser!.uid)
//       .snapshots()
//       .map(
//         (event) => UserModel.fromMap(event.data()!),
//       );
// }

// class ProfileScreen extends StatefulWidget {
//   static const String routeName = '/profile-screen';
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController statusController = TextEditingController();
//   bool? readReciepts;
//   File? image;
//   @override
//   void initState() {
//     super.initState();
//   }

//   void downloadedImage(String url) async {
//     image = await downloadImage(url);
//   }

//   void selectImage() async {
//     image = await pickImageFromGallery(context);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final key = GlobalKey<FormState>();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: const Text("Profile"),
//         elevation: 0.0,
//       ),
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             StreamBuilder<UserModel>(
//                 stream: userData(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Container();
//                   }
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     if (snapshot.hasData) {
//                       nameController.text = snapshot.data!.name;
//                       phoneController.text = snapshot.data!.phoneNumber;
//                       statusController.text = snapshot.data!.status;
//                       // downloadedImage(snapshot.data!.profilePic);
//                       return Center(
//                         child: Form(
//                           key: key,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   ImageFiltered(
//                                     imageFilter: ImageFilter.blur(
//                                         sigmaX: 10.0, sigmaY: 10.0),
//                                     child: Container(
//                                       height: size.height * 0.24,
//                                       decoration: BoxDecoration(
//                                         image: DecorationImage(
//                                             image: NetworkImage(
//                                               snapshot.data!.profilePic,
//                                             ),
//                                             fit: BoxFit.fill),
//                                       ),
//                                     ),
//                                   ),
//                                   Stack(
//                                     children: [
//                                       image == null
//                                           ? CircleAvatar(
//                                               backgroundImage: NetworkImage(
//                                                 snapshot.data!.profilePic,
//                                               ),
//                                               radius: size.height * 0.11,
//                                             )
//                                           : CircleAvatar(
//                                               backgroundImage: FileImage(
//                                                 image!,
//                                               ),
//                                               radius: size.height * 0.11,
//                                             ),
//                                       Positioned(
//                                         bottom: 0,
//                                         left: size.width * 0.35,
//                                         child: CircleAvatar(
//                                           backgroundColor: primaryColor,
//                                           child: IconButton(
//                                             onPressed: selectImage,
//                                             icon: const Icon(
//                                               Icons.add_a_photo,
//                                               color: backgroundColor,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.04,
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//                   }
//                   return const CircularProgressIndicator(
//                     color: primaryColor,
//                   );
//                 }),
//             Padding(
//               padding: EdgeInsets.all(size.width * 0.04),
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: phoneController,
//                     enabled: false,
//                     style: const TextStyle(
//                       color: primaryTextColor,
//                     ), // Set text color to black
//                     decoration: const InputDecoration(
//                       filled: true,
//                       hintText: 'Enter your name',
//                       fillColor: Colors.grey,
//                       disabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: primaryColor),
//                           borderRadius: BorderRadius.all(Radius.circular(5))),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: primaryColor),
//                           borderRadius: BorderRadius.all(Radius.circular(5))),
//                     ),
//                     validator: (value) {
//                       if (value == '' || value == null) {
//                         return 'Name Is Required';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(
//                     height: size.height * 0.02,
//                   ),
//                   TextFormField(
//                     controller: nameController,
//                     style: const TextStyle(
//                       color: secondaryTextColor,
//                     ), // Set text color to black
//                     decoration: inputDecoration.copyWith(),
//                     validator: (value) {
//                       if (value == '' || value == null) {
//                         return 'Name Is Required';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(
//                     height: size.height * 0.02,
//                   ),
//                   TextFormField(
//                     controller: statusController,

//                     style: const TextStyle(
//                       color: secondaryTextColor,
//                     ), // Set text color to black
//                     decoration: inputDecoration.copyWith(hintText: 'Status'),
//                     validator: (value) {
//                       if (value == '' || value == null) {
//                         return 'Status Is Required';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(
//                     height: size.height * 0.02,
//                   ),
//                   RichText(
//                     text: TextSpan(
//                         text: 'Privacy Settings ',
//                         style: const TextStyle(
//                           color: accentColor,
//                         ),
//                         children: [
//                           TextSpan(
//                               text: 'Tap to edit',
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   Navigator.pushNamed(
//                                       context, PrivacyScreen.routeName);
//                                 },
//                               style: const TextStyle(
//                                 color: primaryColor,
//                               ))
//                         ]),
//                   ),
//                   SizedBox(
//                     height: size.height * 0.02,
//                   ),
//                   CustomButton(
//                     onPressed: () {
//                       if (key.currentState!.validate()) {
//                         // ref.read(authControllerProvider).saveUserDataToFirebase(
//                         //     context, nameController.text, image);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Fill The Required Fields')));
//                       }
//                     },
//                     text: "Save",
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

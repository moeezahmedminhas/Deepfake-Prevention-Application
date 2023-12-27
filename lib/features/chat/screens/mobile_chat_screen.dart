import 'package:deepfake_prevention_app/common/widgets/custom_button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';
import '../../../common/widgets/rounded_body.dart';
import '../../../models/user_model.dart';
import '../controller/chat_controller.dart';
import '../widgets/chat_list.dart';
import '../../authentication/controller/auth_controller.dart';
import '../widgets/bottom_chat_field.dart';
// import '../widgets/chat_text_field.dart';

class MobileChatScreen extends ConsumerWidget {
  final String uid;
  static const String routeName = '/mobile-chat-screen';

  const MobileChatScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool lockedChat = ref.watch(lockedChatsProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: FutureBuilder(
              future: ref.read(authControllerProvider).getUserData(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: primaryColor,
                  );
                }
                if (!snap.hasData) {
                  return const CircularProgressIndicator(
                    color: primaryColor,
                  );
                }
                return StreamBuilder<UserModel>(
                    stream: ref.read(authControllerProvider).userDataById(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          color: primaryColor,
                        );
                      }

                      if (snapshot.hasData) {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                snapshot.data!.profilePic,
                              ),
                              radius: size.height * 0.025,
                            ),
                            SizedBox(
                              width: size.width * 0.04,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data!.name),
                                Text(
                                  snapshot.data!.reciepts && snap.data!.reciepts
                                      ? snapshot.data!.isOnline
                                          ? 'online'
                                          : 'offline'
                                      : '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return const CircularProgressIndicator(
                        color: primaryColor,
                      );
                    });
              }),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case 'delete':
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            content: Text(
                              "Are you sure about deleting chat?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: size.height * 0.02,
                              ),
                            ),
                            actions: [
                              SizedBox(
                                width: size.width * 0.3,
                                child: CustomButton(
                                    text: 'Delete Chat',
                                    onPressed: () {
                                      ref
                                          .read(chatControllerProvider)
                                          .deleteWholeChat(context, uid);
                                    }),
                              )
                            ],
                          );
                        });
                    break;

                  case 'lockChat':
                    ref.read(chatControllerProvider).lockChat(
                          otherUserId: uid,
                          isLockedChat: true,
                        );

                    Navigator.of(context).pop();
                    break;
                  case 'unlockChat':
                    ref.read(chatControllerProvider).lockChat(
                          otherUserId: uid,
                          isLockedChat: false,
                        );
                    Navigator.of(context).pop();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> menuItems = [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete Chat'),
                  ),
                ];

                if (lockedChat == true) {
                  menuItems.add(
                    const PopupMenuItem<String>(
                      value: 'unlockChat',
                      child: Text('Unlock Chat'),
                    ),
                  );
                } else {
                  menuItems.add(
                    const PopupMenuItem<String>(
                      value: 'lockChat',
                      child: Text('Lock Chat'),
                    ),
                  );
                }
                //                 // Add 'Block User' only if the user is not the current user
                // if (uid != FirebaseAuth.instance.currentUser!.uid &&
                //     blockStatus == '') {
                //   menuItems.add(
                //     const PopupMenuItem<String>(
                //       value: 'block',
                //       child: Text('Block User'),
                //     ),
                //   );
                // } else {
                //   menuItems.add(
                //     const PopupMenuItem<String>(
                //       value: 'unblock',
                //       child: Text('Unblock User'),
                //     ),
                //   );
                // }
                return menuItems;
              },
              icon: const Icon(Icons.more_vert),
            ),
          ]),
      body: RoundedBody(
        child: Column(
          children: [
            Expanded(child: ChatList(recieverUserid: uid)),
            BottomChatField(receiverUserId: uid)
          ],
        ),
      ),
    );
  }
}



            // StreamBuilder<String>(
            //   stream: ref.watch(chatControllerProvider).getBlockedStatus(uid),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator(); // Show loading indicator while waiting for data
            //     }

            //     if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}'); // Handle errors
            //     }
            //     blockStatus = snapshot.data ?? '';
            //     if (blockStatus.isEmpty) {
            //       return BottomChatField(recieverUserId: uid);
            //     } else {
            //       // Logic when the user is blocked
            //       return Container(
            //         decoration: const BoxDecoration(
            //           color: accentColor,
            //         ),
            //         // height: size.height * 0.09,
            //         width: double.infinity,
            //         child: Center(
            //             child: uid == blockStatus
            //                 ? RichText(
            //                     text: TextSpan(
            //                         text: 'You blocked this user! ',
            //                         style: TextStyle(
            //                             color: primaryColor,
            //                             fontSize: size.height * 0.016),
            //                         children: [
            //                           TextSpan(
            //                               style: TextStyle(
            //                                   color: secondaryTextColor,
            //                                   fontSize: size.height * 0.014),
            //                               text: 'Tap To Unblock',
            //                               recognizer: TapGestureRecognizer()
            //                                 ..onTap = () {
            //                                   ref
            //                                       .read(chatControllerProvider)
            //                                       .blockUser(
            //                                         otherUserId: uid,
            //                                         blockStatus: '',
            //                                       );
            //                                 }),
            //                         ]),
            //                   )
            //                 : const Text('You are blocked by this user')),
            //       ); // Or any other appropriate UI
            //     }
            //   },
            // ),
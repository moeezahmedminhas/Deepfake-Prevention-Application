import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deepfake_prevention_app/features/authentication/controller/auth_controller.dart';
import 'package:deepfake_prevention_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/message.dart';
import '../controller/chat_controller.dart';
import 'my_message_card.dart';
import 'sender_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserid;

  const ChatList({super.key, required this.recieverUserid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();
  UserModel? user;
  UserModel? otherUser;

  bool reciepts = false;
  @override
  void initState() {
    getUserData();

    super.initState();
  }

  void getUserData() async {
    user = await ref.read(authControllerProvider).getUserData();

    reciepts = user!.reciepts;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ref
            .read(authControllerProvider)
            .userDataById(widget.recieverUserid),
        builder: (context, builder) {
          return StreamBuilder<QuerySnapshot>(
              stream: ref
                  .watch(chatControllerProvider)
                  .chatStream(widget.recieverUserid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.none) {
                  return const SizedBox();
                }

                SchedulerBinding.instance.addPostFrameCallback((_) {
                  messageController
                      .jumpTo(messageController.position.maxScrollExtent);
                });
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Say Hii! 👋', style: TextStyle(fontSize: 20)),
                  );
                }

                final messagesSnapshot = snapshot.data!.docs;
                return ListView.builder(
                  controller: messageController,
                  itemCount: messagesSnapshot.length,
                  itemBuilder: (context, index) {
                    var messageData = Message.fromMap(
                        messagesSnapshot[index].data() as Map<String, dynamic>);

                    var timeSent = DateFormat.Hm().format(messageData.timeSent);
                    if (!messageData.isSeen &&
                        // messageData.recieverid !=
                        //     FirebaseAuth.instance.currentUser!.uid
                        //     &&
                        reciepts &&
                        builder.data!.reciepts) {
                      ref.read(chatControllerProvider).setChatMessageSeen(
                            context,
                            widget.recieverUserid,
                            messageData.messageId,
                          );
                    }
                    if (messageData.senderId ==
                        FirebaseAuth.instance.currentUser!.uid) {
                      return MyMessageCard(
                        message: messageData.text,
                        date: timeSent,
                        type: messageData.type,
                        isSeen: messageData.isSeen,
                      );
                    }
                    return SenderMessageCard(
                      message: messageData.text,
                      date: timeSent,
                      type: messageData.type,
                      isSeen: messageData.isSeen,
                    );
                  },
                );
              });
        });
  }
}





// import 'package:deepfake_prevention_app/features/authentication/controller/auth_controller.dart';
// import 'package:deepfake_prevention_app/models/user_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// import '../../../common/widgets/loader.dart';
// import '../../../models/message.dart';
// import '../controller/chat_controller.dart';
// import 'my_message_card.dart';
// import 'sender_message_card.dart';

// class ChatList extends ConsumerStatefulWidget {
//   final String recieverUserid;

//   const ChatList({super.key, required this.recieverUserid});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
// }

// class _ChatListState extends ConsumerState<ChatList> {
//   final ScrollController messageController = ScrollController();
//   UserModel? user;
//   UserModel? otherUser;

//   bool reciepts = false;
//   @override
//   void initState() {
//     getUserData();

//     super.initState();
//   }

//   void getUserData() async {
//     user = await ref.read(authControllerProvider).getUserData();

//     reciepts = user!.reciepts;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: ref
//             .read(authControllerProvider)
//             .userDataById(widget.recieverUserid),
//         builder: (context, builder) {
//           return StreamBuilder<List<Message>>(
//               stream: ref
//                   .watch(chatControllerProvider)
//                   .chatStream(widget.recieverUserid),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Loader();
//                 }

//                 SchedulerBinding.instance.addPostFrameCallback((_) {
//                   messageController
//                       .jumpTo(messageController.position.maxScrollExtent);
//                 });
//                 return ListView.builder(
//                   controller: messageController,
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     print(snapshot.connectionState);

//                     var messageData = snapshot.data![index];
//                     var timeSent = DateFormat.Hm().format(messageData.timeSent);
//                     if (!messageData.isSeen &&
//                         // messageData.recieverid !=
//                         //     FirebaseAuth.instance.currentUser!.uid
//                         //     &&
//                         reciepts &&
//                         builder.data!.reciepts) {
//                       ref.read(chatControllerProvider).setChatMessageSeen(
//                             context,
//                             widget.recieverUserid,
//                             messageData.messageId,
//                           );
//                     }
//                     if (messageData.senderId ==
//                         FirebaseAuth.instance.currentUser!.uid) {
//                       return MyMessageCard(
//                         message: messageData.text,
//                         date: timeSent,
//                         type: messageData.type,
//                         isSeen: messageData.isSeen,
//                       );
//                     }
//                     return SenderMessageCard(
//                       message: messageData.text,
//                       date: timeSent,
//                       type: messageData.type,
//                       isSeen: messageData.isSeen,
//                     );
//                   },
//                 );


//               });
//         });
//   }
// }

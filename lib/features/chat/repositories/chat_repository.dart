import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../common/enums/message_enum.dart';
import '../../../common/repositories/common_firebase_repository.dart';
import '../../../common/utils/utils.dart';
import '../../../models/message.dart';
import '../../../models/user_model.dart';
import '../../../models/chat_contact.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});
  Stream<List<ChatContact>> getChatContacts(bool isLocked) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);
        final temp = ChatContact(
          name: user.name,
          profilePic: user.profilePic,
          phoneNumber: user.phoneNumber,
          contactId: chatContact.contactId,
          timeSent: chatContact.timeSent,
          lastMessage: chatContact.lastMessage,
          // blockedBy: chatContact.blockedBy,
          isLocked: chatContact.isLocked,
        );
        if (isLocked && chatContact.isLocked) {
          contacts.add(temp);
        } else if (!isLocked && !chatContact.isLocked) {
          contacts.add(temp);
        }
      }
      return contacts;
    });
  }

  // Stream<List<Message>> getChatStream(String recieverUserId) {
  //   return firestore
  //       .collection('users')
  //       .doc(auth.currentUser!.uid)
  //       .collection('chats')
  //       .doc(recieverUserId)
  //       .collection('messages')
  //       .orderBy('timeSent')
  //       .snapshots()
  //       .map((event) {
  //     List<Message> messages = [];
  //     for (var document in event.docs) {
  //       messages.add(Message.fromMap(document.data()));
  //     }
  //     return messages;
  //   });
  // }

  Stream<QuerySnapshot> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots();
  }

  void _saveDataToContactSubCollection(
    UserModel senderUserData,
    UserModel recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        phoneNumber: senderUserData.phoneNumber,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        // blockedBy: '',
        isLocked: false);
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          recieverChatContact.toMap(),
        );
    var senderChatContact = ChatContact(
        name: recieverUserData.name,
        profilePic: recieverUserData.profilePic,
        phoneNumber: recieverUserData.phoneNumber,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        // blockedBy: '',
        isLocked: false);
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void lockChat({required otherUserId, required isLocked}) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(otherUserId)
        .update(
      {
        'isLocked': isLocked,
      },
    );
  }

  Future<List<String>> getAllDevices(String uid) async {
    try {
      // Create a list to store device IDs
      List<String> deviceIds = [];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('devices')
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final deviceId = doc.data()['device'] as String;
          deviceIds.add(deviceId);
        }
      }

      return deviceIds;
    } catch (e) {
      return [];
    }
  }

  void sendNotificationToDevice(String deviceId, String userName,
      String messageText, String senderId) async {
    var data = {
      'to': deviceId,
      'notification': {
        'title': userName,
        'body': messageText,
      },
      'data': {
        'type': 'msg',
        'uid': FirebaseAuth.instance.currentUser!.uid
      } // Fix the senderId key here
    };

    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAApqtVGhA:APA91bHg28ENWe9w31FMpDxmNM3qQzedEZmmTdrlL0j6WyJETgLbAyPYPwiXmr7K-gIwYFPVPDcwjczJEjihOzw3dApjU0UboBFvCpipQ8cPV3VStJM1sA2C0Z9vMDPUIGhTL89-HKYx',
        },
      );
      if (kDebugMode) {
        if (response.statusCode == 200) {
          print('Notification sent successfully.');
        } else {
          print(
              'Failed to send notification. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      log('Error sending notification: $error');
    }
  }

  _saveMsgToMsgSubCollection(
      {required String recieverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String userName,
      required recieverUserName,
      required MessageEnum messageType}) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );
    List<String> deviceIds = await getAllDevices(recieverUserId);
    for (var deviceId in deviceIds) {
      sendNotificationToDevice(
          deviceId,
          userName,
          messageType == MessageEnum.text
              ? text
              : getMessageByMessageType(messageType),
          auth.currentUser!.uid);
    }

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage(
      {required BuildContext context,
      required String text,
      required String recievedUserId,
      required UserModel senderUser}) async {
    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;
      var messageId = const Uuid().v1();

      var userDataMap =
          await firestore.collection('users').doc(recievedUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);
      _saveDataToContactSubCollection(
          senderUser, recieverUserData, text, timeSent, recievedUserId);
      _saveMsgToMsgSubCollection(
          recieverUserId: recievedUserId,
          text: text,
          timeSent: timeSent,
          messageId: messageId,
          userName: senderUser.name,
          recieverUserName: recieverUserData.name,
          messageType: MessageEnum.text);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required recieverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
              file);
      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      UserModel recieverUserData = UserModel.fromMap(userDataMap.data()!);
      String contactMsg;
      contactMsg = getMessageByMessageType(messageEnum);
      _saveDataToContactSubCollection(senderUserData, recieverUserData,
          contactMsg, timeSent, recieverUserId);
      _saveMsgToMsgSubCollection(
          recieverUserId: recieverUserId,
          text: imageUrl,
          timeSent: timeSent,
          messageId: messageId,
          userName: senderUserData.name,
          recieverUserName: recieverUserData.name,
          messageType: messageEnum);
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  void deleteWholeChat(
    BuildContext context,
    String recieverUserId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .delete();
      var messagesCollection = firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages');

      var messagesSnapshot = await messagesCollection.get();
      WriteBatch batch = firestore.batch();

      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      if (!context.mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      batch.commit();
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context: context, content: e.toString());
    }
  }

  //   Stream<String> getBlockStatus(String receiverUserId) {
  //   return firestore
  //       .collection('users')
  //       .doc(auth.currentUser!.uid)
  //       .collection('chats')
  //       .doc(receiverUserId)
  //       .snapshots()
  //       .map((snapshot) {
  //     if (snapshot.exists && snapshot.data()!.containsKey('blockedBy')) {
  //       return snapshot.data()!['blockedBy'] as String;
  //     } else {
  //       return ''; // Default value if blockStatus is not set
  //     }
  //   });
  // }
  // void blockUser({required otherUserId, required blockStatus}) async {
  //   await firestore
  //       .collection('users')
  //       .doc(auth.currentUser!.uid)
  //       .collection('chats')
  //       .doc(otherUserId)
  //       .update(
  //     {
  //       'blockedBy': blockStatus,
  //     },
  //   );
  //   await firestore
  //       .collection('users')
  //       .doc(otherUserId)
  //       .collection('chats')
  //       .doc(auth.currentUser!.uid)
  //       .update(
  //     {
  //       'blockedBy': blockStatus,
  //     },
  //   );
  // }
}

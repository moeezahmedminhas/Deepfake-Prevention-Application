import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/enums/message_enum.dart';
// import '../../../models/message.dart';
import '../../authentication/repository/auth_respository.dart';
import '../../../models/chat_contact.dart';
import '../repositories/chat_repository.dart';

final chatControllerProvider = Provider(
  (ref) => ChatController(
      chatRepository: ref.watch(chatRepositoryProvider), ref: ref),
);
final lockedChatsProvider = StateProvider<bool>((ref) {
  return false;
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.chatRepository, required this.ref});
  void sendTextMessage(
      BuildContext context, String text, String recieverUserId) {
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
              context: context,
              text: text,
              recievedUserId: recieverUserId,
              senderUser: value!),
        );
  }

  void sendFileMessage(BuildContext context, File file, String recieverUserId,
      MessageEnum messageEnum) {
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendFileMessage(
              context: context,
              file: file,
              recieverUserId: recieverUserId,
              ref: ref,
              messageEnum: messageEnum,
              senderUserData: value!),
        );
  }

  Stream<List<ChatContact>> chatContacts(bool isLocked) {
    return chatRepository.getChatContacts(isLocked);
  }

  void deleteWholeChat(BuildContext context, String recieverUserID) {
    chatRepository.deleteWholeChat(context, recieverUserID);
  }

  void lockChat({required otherUserId, required isLockedChat}) {
    chatRepository.lockChat(
      otherUserId: otherUserId,
      isLocked: isLockedChat,
    );
  }

  // Stream<List<Message>> chatStream(String recieverUserId) {
  //   return chatRepository.getChatStream(recieverUserId);
  // }
  Stream<QuerySnapshot> chatStream(String recieverUserId) {
    return chatRepository.getChatStream(recieverUserId);
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) {
    chatRepository.setChatMessageSeen(
      context,
      recieverUserId,
      messageId,
    );
  }

  // Stream<String> getBlockedStatus(String receiverUserId) {
  //   return chatRepository.getBlockStatus(receiverUserId);
  // }

  // void blockUser({required otherUserId, required blockStatus}) {
  //   chatRepository.blockUser(
  //       otherUserId: otherUserId, blockStatus: blockStatus);
  // }
}

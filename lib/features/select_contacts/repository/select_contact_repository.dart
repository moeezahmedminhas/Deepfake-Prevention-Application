import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/utils.dart';
import '../../../models/user_model.dart';
import '../../chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider(
    (ref) => SelectContactRepository(firestore: FirebaseFirestore.instance));

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({required this.firestore});
  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];

    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
          withAccounts: true,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      String selectedPhoneNum =
          selectedContact.phones[0].number.replaceAll(' ', '');
      if (selectedPhoneNum[0] == '0') {
        selectedPhoneNum = selectedPhoneNum.replaceFirst('0', '+92');
      }

      // Query Firestore directly for the phone number
      var userQuery = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: selectedPhoneNum)
          .get();

      if (userQuery.docs.isEmpty) {
        if (context.mounted) {
          showSnackBar(context: context, content: "Contact Not Found");
        }
        return;
      }

      var userData = UserModel.fromMap(userQuery.docs[0].data());
      var chatData = await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(userData.uid)
          .get();

      if (chatData.data() != null && chatData.data()!['isLocked'] == true) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sorry, this chat is locked')));
        return;
      }

      if (context.mounted) {
        Navigator.popAndPushNamed(context, MobileChatScreen.routeName,
            arguments: {'name': userData.name, 'uid': userData.uid});
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
            context: context, content: "An error occurred: ${e.toString()}");
      }
    }
  }
}

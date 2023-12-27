import 'package:deepfake_prevention_app/common/utils/colors.dart';
import 'package:deepfake_prevention_app/features/chat/widgets/change_lock_chats_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../landing/screens/main_screen.dart';
import '../controller/chat_controller.dart';
import '../../../models/chat_contact.dart';
import '../widgets/chat_contact_item.dart';

List<ChatContact> filterContacts(List<ChatContact> allContacts, String query) {
  return allContacts
      .where(
          (contact) => contact.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

class LockedChatsScreen extends ConsumerStatefulWidget {
  const LockedChatsScreen({super.key});
  static const routeName = '/locked-chats-screen';
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LockedChatsScreenState();
}

class _LockedChatsScreenState extends ConsumerState<LockedChatsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = ref.watch(chatControllerProvider);
    final searchEnabled = ref.watch(searchEnabledProvider);
    final searchQuery = ref.watch(searchTextProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: primaryTextColor,
        elevation: 0,
        title: Text(
          "Locked Chats",
          style: textStyle.copyWith(color: primaryTextColor),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(lockedChatsProvider.notifier).state = false;
            Navigator.of(context).pop();
          },
        ),
        actions: const [
          ChangeLockedItemsPassWidget(),
        ],
      ),
      body: StreamBuilder<List<ChatContact>>(
        stream: chatController.chatContacts(true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No contacts available'));
          }

          List<ChatContact> contacts = snapshot.data!;
          List<ChatContact> filteredContacts =
              searchEnabled ? filterContacts(contacts, searchQuery) : contacts;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: filteredContacts.length,
            itemBuilder: (context, index) {
              var chatContact = filteredContacts[index];
              return ChatContactItem(chatContactData: chatContact);
            },
          );
        },
      ),
    );
  }
}

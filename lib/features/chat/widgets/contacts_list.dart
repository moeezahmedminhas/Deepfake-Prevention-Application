import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/loader.dart';
import '../../landing/screens/main_screen.dart';
import '../controller/chat_controller.dart';
import '../../../models/chat_contact.dart';
import 'chat_contact_item.dart';

List<ChatContact> filterContacts(List<ChatContact> allContacts, String query) {
  return allContacts
      .where(
          (contact) => contact.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

class ContactsList extends ConsumerWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatController = ref.watch(chatControllerProvider);
    final searchEnabled = ref.watch(searchEnabledProvider);
    final searchQuery = ref.watch(searchTextProvider);

    return StreamBuilder<List<ChatContact>>(
      stream: chatController.chatContacts(false),
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
    );
  }
}

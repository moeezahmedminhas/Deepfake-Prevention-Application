import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';
import '../../../common/widgets/error.dart';
import '../../../common/widgets/loader.dart';
import '../controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerStatefulWidget {
  const SelectContactsScreen({super.key});
  static const routeName = '/select-contact';

  @override
  ConsumerState<SelectContactsScreen> createState() =>
      _SelectContactsScreenState();
}

class _SelectContactsScreenState extends ConsumerState<SelectContactsScreen> {
  bool isSearchActive = false;
  TextEditingController searchController = TextEditingController();

  void selectContact(Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  void startSearch() {
    setState(() {
      isSearchActive = true;
    });
  }

  void endSearch() {
    setState(() {
      isSearchActive = false;
      searchController.clear();
    });
  }

  List<Contact> filterContacts(List<Contact> allContacts, String query) {
    return allContacts
        .where((contact) =>
            contact.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: isSearchActive
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
                style: const TextStyle(color: Colors.white),
                onChanged: (query) => setState(() {}),
              )
            : const Text("Select Contact"),
        actions: [
          if (!isSearchActive)
            IconButton(
              onPressed: startSearch,
              icon: const Icon(Icons.search),
            ),
          if (isSearchActive)
            IconButton(
              onPressed: endSearch,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: ref.watch(getContactProvider).when(
            data: (contactList) {
              List<Contact> filteredList = isSearchActive
                  ? filterContacts(contactList, searchController.text)
                  : contactList;

              return ListView.builder(
                itemBuilder: (context, index) {
                  final contact = filteredList[index];

                  return InkWell(
                    onTap: () {
                      selectContact(contact, context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.02),
                      child: ListTile(
                        title: Text(
                          contact.displayName,
                          style: const TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),
                        leading: contact.photo == null
                            ? CircleAvatar(
                                backgroundImage: const NetworkImage(
                                  'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                                ),
                                radius: size.width * 0.05,
                              )
                            : CircleAvatar(
                                backgroundImage: MemoryImage(contact.photo!),
                                radius: size.width * 0.05,
                              ),
                      ),
                    ),
                  );
                },
                itemCount: filteredList.length,
              );
            },
            error: (error, trace) {
              return ErrorScreen(error: error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}

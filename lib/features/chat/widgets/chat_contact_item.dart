import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/utils/colors.dart';
import '../../../models/chat_contact.dart';
import '../screens/mobile_chat_screen.dart';

class ChatContactItem extends StatelessWidget {
  const ChatContactItem({
    super.key,
    required this.chatContactData,
  });

  final ChatContact chatContactData;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.02),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MobileChatScreen(
                    uid: chatContactData.contactId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: screenSize.width * 0.02),
              child: ListTile(
                title: Text(
                  chatContactData.name,
                  style: const TextStyle(
                    fontSize: 18,
                    color: secondaryTextColor,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    chatContactData.lastMessage,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 15,
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                  ),
                ),
                leading: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenSize.height * 0.02),
                                    child: Image.network(
                                      chatContactData.profilePic,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenSize.height * 0.02,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        text: "Phone Number:   ",
                                        style: const TextStyle(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.w500),
                                        children: [
                                          TextSpan(
                                            text: chatContactData.phoneNumber,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor),
                                          )
                                        ]),
                                  )
                                ],
                              ),
                            ));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      chatContactData.profilePic,
                    ),
                    radius: 30,
                  ),
                ),
                trailing: Text(
                  DateFormat.Hm().format(chatContactData.timeSent),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: dividerColor),
        ],
      ),
    );
  }
}

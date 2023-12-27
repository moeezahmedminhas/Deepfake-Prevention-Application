import 'dart:convert';
import 'package:encrypt/encrypt.dart';

import '../common/utils/utils.dart';

class ChatContact {
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  final String phoneNumber;
  final bool isLocked;
  ChatContact(
      {required this.name,
      required this.profilePic,
      required this.contactId,
      required this.timeSent,
      required this.lastMessage,
      required this.phoneNumber,
      // required this.blockedBy,
      required this.isLocked});

  Map<String, dynamic> toMap() {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(secretKey, mode: AESMode.cbc));

    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': encrypter.encrypt(lastMessage, iv: iv).base64,
      'iv': iv.base64, // Store the IV
      'phoneNumber': phoneNumber,
      // 'blockedBy': blockedBy,
      'isLocked': isLocked
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    final iv = IV.fromBase64(map['iv'] as String);
    final encrypter = Encrypter(AES(secretKey, mode: AESMode.cbc));
    return ChatContact(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      contactId: map['contactId'] as String,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent'] as int),
      lastMessage: encrypter
          .decrypt(Encrypted.fromBase64(map['lastMessage'] as String), iv: iv),
      phoneNumber: map['phoneNumber'] as String,
      // blockedBy: map['blockedBy'] as String,
      isLocked: map['isLocked'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatContact.fromJson(String source) =>
      ChatContact.fromMap(json.decode(source) as Map<String, dynamic>);
}

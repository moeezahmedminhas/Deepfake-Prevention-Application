// import 'package:encrypt/encrypt.dart';

// import '../common/enums/message_enum.dart';
// import '../common/utils/utils.dart';

// class Message {
//   final String senderId;
//   final String recieverid;
//   final String text;
//   final MessageEnum type;
//   final DateTime timeSent;
//   final String messageId;
//   final bool isSeen;
//   // final String repliedMessage;
//   // final String repliedTo;
//   // final MessageEnum repliedMessageType;

//   Message({
//     required this.senderId,
//     required this.recieverid,
//     required this.text,
//     required this.type,
//     required this.timeSent,
//     required this.messageId,
//     required this.isSeen,
//     // required this.repliedMessage,
//     // required this.repliedTo,
//     // required this.repliedMessageType,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'senderId': senderId,
//       'recieverid': recieverid,
//       'text': text,
//       'type': type.type,
//       'timeSent': timeSent.millisecondsSinceEpoch,
//       'messageId': messageId,
//       'isSeen': isSeen,
//       // 'repliedMessage': repliedMessage,
//       // 'repliedTo': repliedTo,
//       // 'repliedMessageType': repliedMessageType.type,
//     };
//   }

//   factory Message.fromMap(Map<String, dynamic> map) {
//     String text = map['text'] ?? '';
//     return Message(
//       senderId: map['senderId'] ?? '',
//       recieverid: map['recieverid'] ?? '',
//       text: text,
//       type: (map['type'] as String).toEnum(),
//       timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
//       messageId: map['messageId'] ?? '',
//       isSeen: map['isSeen'] ?? false,
//       // repliedMessage: map['repliedMessage'] ?? '',
//       // repliedTo: map['repliedTo'] ?? '',
//       // repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
//     );
//   }
// }

import 'package:encrypt/encrypt.dart';
import '../common/enums/message_enum.dart';
import '../common/utils/utils.dart'; // Ensure secretKey is defined here

class Message {
  final String senderId;
  final String recieverid;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;

  Message({
    required this.senderId,
    required this.recieverid,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
  });

  Map<String, dynamic> toMap() {
    final iv = IV.fromSecureRandom(16); // Generate a random IV
    final encrypter = Encrypter(AES(secretKey, mode: AESMode.cbc));

    return {
      'senderId': senderId,
      'recieverid': recieverid,
      'text': encrypter.encrypt(text, iv: iv).base64,
      'iv': iv.base64, // Store the IV as well
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final iv = IV.fromBase64(map['iv']);
    final encrypter = Encrypter(AES(secretKey, mode: AESMode.cbc));

    return Message(
      senderId: map['senderId'] ?? '',
      recieverid: map['recieverid'] ?? '',
      text: encrypter.decrypt(Encrypted.fromBase64(map['text']), iv: iv),
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      isSeen: map['isSeen'] ?? false,
    );
  }
}

import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'colors.dart';

final secretKey = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

void copyToClipboard({required context, required text}) {
  // Copy watermark to clipboard
  Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Text copied to clipboard')));
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    if (context.mounted) {
      showSnackBar(context: context, content: e.toString());
    }
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    if (context.mounted) {
      showSnackBar(context: context, content: e.toString());
    }
  }
  return video;
}

final fieldStyle = InputDecoration(
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: primaryColor, width: 1),
    borderRadius: BorderRadius.circular(5),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: primaryColor, width: 1),
    borderRadius: BorderRadius.circular(5),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: primaryColor, width: 1),
    borderRadius: BorderRadius.circular(5),
  ),
  labelStyle: const TextStyle(color: primaryColor),
);

const textStyle = TextStyle(
  color: Colors.black,
  fontFamily: 'sfui',
  fontWeight: FontWeight.w600,
);

// final List<String> urlOptions = [
//   'http://localhost:8000/process_image/',
//   'http://localhost:8000/decode_image/',
//   'http://localhost:8000/detect_image/',
// ];
final List<String> urlVideos = [
  'http://localhost:8000/process_media/',
  'http://localhost:8000/decode_media/',
  // 'http://localhost:8000/detect_image/',
];
final List<String> urlImages = [
  'https://moeezminhas-deepfakeapp.hf.space/process_image/',
  'https://moeezminhas-deepfakeapp.hf.space/decode_image/',
  'https://moeezminhas-deepfakeapp.hf.space/detect_image/',
];

const privacyPolicyText = '''
Privacy Policy for MojoTech's Deepfake Prevention Application

Last Updated: December 20, 2023

This Privacy Policy explains how MojoTech we collects, uses, shares, and protects user information obtained through the Deepfake Prevention Application (the "App"). By using the App, you agree to the terms outlined in this Privacy Policy.

Information We Collect
  
User-Provided Information:

When you create an account, we collect the information you provide, such as your name, profile picture, and contact details.
Automatically Collected Information:

We may collect certain information automatically when you use the App, including device information, usage patterns, and browsing history.
Deepfake Prevention:

The App includes features related to deepfake prevention, such as encoding, decoding, and detecting deepfakes in images. Please note that images processed through these features may be temporarily stored for processing purposes.
Chatting Functionality:

The App allows users to send text messages, photos, videos, and voice messages. The content of these messages may be stored temporarily to facilitate real-time communication.
Locked Chats:

The App includes a feature that allows users to lock specific chat conversations. Information about locked chats, including passwords, may be stored locally on the device.
Video Watermarking:

The App offers video watermarking functionality to enhance the security and identification of videos. Watermarked videos may be temporarily stored for processing purposes.
How We Use Your Information
Providing Services:

We use the collected information to provide and enhance the services offered through the App, including deepfake prevention, chatting, locked chats, and video watermarking.
Communication:

We may use your contact information to send important notifications and updates related to the App.
Improving User Experience:

We analyze user behavior and feedback to improve the functionality and user experience of the App.
Information Sharing
We do not sell, trade, or rent your personal information to third parties. However, we may share information in the following circumstances:

With Your Consent:

We may share your information when you give us explicit consent to do so.
For Legal Reasons:

We may disclose your information to comply with legal obligations or respond to lawful requests.
Data Security
We implement security measures to protect your information from unauthorized access, disclosure, alteration, or destruction. However, no method of transmission over the internet or electronic storage is entirely secure.

Changes to Privacy Policy
We may update this Privacy Policy to reflect changes in our practices or for other operational, legal, or regulatory reasons. We encourage you to review this policy periodically.

Contact Us
If you have any questions or concerns about this Privacy Policy, please contact us at moeezahmedpersonal@gmail.com
''';

// const inputDecoration = InputDecoration(
//   filled: true,
//   hintText: 'Name',
//   fillColor: accentColor,
//   enabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: primaryColor),
//       borderRadius: BorderRadius.all(Radius.circular(5))),
//   focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: primaryColor),
//       borderRadius: BorderRadius.all(Radius.circular(5))),
// );

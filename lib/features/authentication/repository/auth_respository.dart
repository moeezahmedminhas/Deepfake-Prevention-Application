import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deepfake_prevention_app/features/authentication/screens/login_screen.dart';
import 'package:deepfake_prevention_app/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/repositories/common_firebase_repository.dart';
import '../../../common/utils/utils.dart';
import '../../../models/user_model.dart';
import '../../landing/screens/main_screen.dart';
import '../controller/auth_controller.dart';
import '../screens/otp_screen.dart';
import '../screens/user_information_screen.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));
final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  AuthRepository({required this.auth, required this.firestore});

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();

    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void updateReciepts({required reciepts}) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'reciepts': reciepts});
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await auth.signInWithCredential(credential);
          } catch (e) {
            if (context.mounted) {
              showSnackBar(context: context, content: e.toString());
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (context.mounted) {
            showSnackBar(
                context: context, content: e.message ?? 'Verification failed');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          if (context.mounted) {
            Navigator.pushNamed(context, OTPScreen.routeName,
                arguments: verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showSnackBar(
            context: context, content: e.message ?? 'Auth exception occurred');
      }
    } catch (e) {
      // Handle other exceptions
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          UserInformationScreen.routeName,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.message!);
      }
    }
  }

  void updateUserData(UserModel user) async {
    String uid = auth.currentUser!.uid;
    await firestore.collection('users').doc(uid).set(user.toMap());
  }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      var userSnapshot = await firestore.collection('users').doc(uid).get();
      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
      }
      if (userSnapshot.exists) {
        if (!context.mounted) return;
        updateUserDataToFirebase(
            name: name,
            profilePic: profilePic,
            status: 'Welcome To Deepfake Prevention Application',
            ref: ref,
            context: context);
      } else {
        var user = UserModel(
          name: name,
          reciepts: true,
          status: 'Welcome To Deepfake Prevention Application',
          uid: uid,
          profilePic: photoUrl,
          isOnline: true,
          phoneNumber: auth.currentUser!.phoneNumber!,
          lockedChats: [],
          lockChatPassword: "",
        );
        await firestore.collection('users').doc(uid).set(user.toMap());
      }

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  void updateUserDataToFirebase({
    required String name,
    required File? profilePic,
    required String status,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      if (profilePic != null) {
        String photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
        await firestore
            .collection('users')
            .doc(uid)
            .update({'profilePic': photoUrl});
      }
      await firestore
          .collection('users')
          .doc(uid)
          .update({'name': name, 'status': status});
      if (context.mounted) {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const MobileLayoutScreen(),
        //   ),
        //   (route) => false,
        // );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Your Data is Updated"),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  Stream<UserModel> userData(String uid) {
    return firestore.collection('users').doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data()!),
        );
  }

  setUserLockedChatsPassword(String password) async {
    firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({"lockChatPassword": password});
  }

  void setUserOnlineStatus(bool status) {
    firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({"isOnline": status});
  }

  void addDevice() async {
    final notificationServices = NotificationServices();
    final deviceToken = await notificationServices.getDeviceToken();
    await firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('devices')
        .add({'device': deviceToken});
    // .doc(deviceToken)
    // .set({'device': deviceToken});
  }

  Future<List<String>> getAllDevices(String uid) async {
    try {
      // Create a list to store device IDs
      List<String> deviceIds = [];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
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

  void removeDevice() async {
    final notificationServices = NotificationServices();
    final deviceToken = await notificationServices.getDeviceToken();

    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('devices')
        .where('device', isEqualTo: deviceToken)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentReference = querySnapshot.docs.first.reference;
      await documentReference.delete();
    }
  }

  Future<void> logout(BuildContext context) async {
    removeDevice();
    setUserOnlineStatus(false);
    await auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName, ModalRoute.withName(MainScreen.routeName));
  }
}

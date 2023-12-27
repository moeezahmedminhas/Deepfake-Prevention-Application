import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../repository/auth_respository.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;
  AuthController({required this.authRepository, required this.ref});

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.signInWithPhone(context, phoneNumber);
  }

  void verifyOTP(BuildContext context, String verificationId, String userOTP) {
    authRepository.verifyOTP(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  void saveUserDataToFirebase(
      BuildContext context, String name, File? profilePic) {
    authRepository.saveUserDataToFirebase(
      name: name,
      profilePic: profilePic,
      ref: ref,
      context: context,
    );
  }

  void updateUserDataToFirebase(
      BuildContext context, String name, File? profilePic, String status) {
    authRepository.updateUserDataToFirebase(
      name: name,
      profilePic: profilePic,
      status: status,
      ref: ref,
      context: context,
    );
  }

  void updateReciepts(bool reciepts) {
    return authRepository.updateReciepts(reciepts: reciepts);
  }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }

  void setUserOnlineStatus(bool isOnline) async {
    authRepository.setUserOnlineStatus(isOnline);
  }

  Future<List<String>> getAllDevices(String uid) async {
    return authRepository.getAllDevices(uid);
  }

  setUserLockedChatsPassword(String password) async {
    return authRepository.setUserLockedChatsPassword(password);
  }

  void addDevice() {
    authRepository.addDevice();
  }

  void logout(BuildContext context) {
    authRepository.logout(context);
  }
}

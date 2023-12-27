import 'package:deepfake_prevention_app/common/widgets/loader.dart';
import 'package:deepfake_prevention_app/features/authentication/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  static const routeName = 'privacy-settings-screen';
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Edit Privacy"),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: StreamBuilder(
          stream: ref
              .watch(authControllerProvider)
              .userDataById(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Loader(),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Read Reciepts',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: size.height * 0.02),
                ),
                Switch(
                    activeColor: accentColor,
                    value: snapshot.data!.reciepts,
                    onChanged: (value) {
                      ref.read(authControllerProvider).updateReciepts(value);
                    })
              ],
            );
          },
        ),
      ),
    );
  }
}

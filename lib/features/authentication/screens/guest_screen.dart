import 'package:deepfake_prevention_app/features/deepfake/screens/deepfake_prevention.dart';
import 'package:deepfake_prevention_app/features/landing/screens/landing_screen.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/colors.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});
  static const routeName = '/guest-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Hi! Guest"),
        elevation: 0,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, LandingScreen.routeName, (route) => false);
              },
              icon: const Icon(Icons.login_outlined))
        ],
      ),
      body: const DeepfakePreventionScreen(),
    );
  }
}

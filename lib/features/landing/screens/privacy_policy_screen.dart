import 'package:deepfake_prevention_app/common/utils/utils.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  static const routeName = '/privacy-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: const SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Center(child: Text(privacyPolicyText)),
      )),
    );
  }
}

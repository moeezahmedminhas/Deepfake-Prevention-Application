import 'package:deepfake_prevention_app/features/landing/screens/privacy_policy_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../common/utils/colors.dart';
import '../../../common/widgets/custom_button.dart';
import '../../authentication/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  static const routeName = '/landing-screen';

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              'Deepfake Prevention App',
              style: TextStyle(
                fontSize: size.height * 0.03,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: size.height / 9),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.06),
              child: Image.asset(
                'assets/backgroundImage.png',
                width: size.width * 0.65,
                height: size.height * 0.3,
              ),
            ),
            SizedBox(height: size.height / 9),
            // const Padding(
            //   padding: EdgeInsets.all(15.0),
            //   child: Text(
            //     'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
            //     style: TextStyle(color: lightGrayColor),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.03),
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Read our Privacy Policy.",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context)
                              .pushNamed(PrivacyPolicyScreen.routeName);
                        },
                      style: const TextStyle(color: primaryColor),
                      children: const [
                        TextSpan(
                            text:
                                ' Tap "Agree and continue" to accept the Terms of Service.')
                      ])),
            ),
            SizedBox(
              width: size.width * 0.75,
              child: CustomButton(
                text: 'AGREE AND CONTINUE',
                onPressed: () => navigateToLoginScreen(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

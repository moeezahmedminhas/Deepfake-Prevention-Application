import 'package:country_picker/country_picker.dart';
import 'package:deepfake_prevention_app/features/authentication/screens/guest_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/custom_button.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  final key = GlobalKey<FormState>();

  Country? country;
  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country countryy) {
          setState(() {
            country = countryy;
          });
        });
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    } else {
      showSnackBar(context: context, content: 'Fill out all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: key,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Deepfake Prevention Application will need to verify your phone number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: size.height * 0.01),
                TextButton(
                  onPressed: pickCountry,
                  child: const Text('Pick Country'),
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    country != null
                        ? Text('+${country!.phoneCode}')
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: size.width * 0.7,
                      child: TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "Phone number",
                        ),
                        validator: (value) {
                          if (value == null) {
                            return "phone number is required field";
                          }
                          if (value.length < 10) {
                            return "phone number is incorrect";
                          }
                          if (value.contains(' ')) {
                            return "phone number should be without spaces";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.5),
                SizedBox(
                  width: size.width * 0.3,
                  child: CustomButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        sendPhoneNumber();
                      }
                    },
                    text: 'NEXT',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.03),
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: "Don't wanna join?",
                          style: const TextStyle(color: accentColor),
                          children: [
                            TextSpan(
                              text: ' Continue as guest.',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      GuestScreen.routeName, (route) => false);
                                },
                              style: const TextStyle(color: primaryColor),
                            )
                          ])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

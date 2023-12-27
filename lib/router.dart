import 'package:deepfake_prevention_app/features/authentication/screens/guest_screen.dart';
import 'package:deepfake_prevention_app/features/authentication/screens/privacy_settings_screen.dart';
import 'package:deepfake_prevention_app/features/chat/screens/locked_chats_screen.dart';
import 'package:deepfake_prevention_app/features/deepfake/screens/deepfake_data_screen.dart';
import 'package:deepfake_prevention_app/features/landing/screens/landing_screen.dart';
import 'package:flutter/material.dart';

import 'common/widgets/error.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/otp_screen.dart';
import 'features/authentication/screens/profile_screen.dart';
import 'features/authentication/screens/user_information_screen.dart';
import 'features/chat/screens/mobile_chat_screen.dart';
import 'features/landing/screens/privacy_policy_screen.dart';
import 'features/select_contacts/screens/select_contacts_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LandingScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LandingScreen());
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case GuestScreen.routeName:
      return MaterialPageRoute(builder: (context) => const GuestScreen());
    case PrivacyPolicyScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const PrivacyPolicyScreen());
    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const SelectContactsScreen());
    case ProfileScreen.routeName:
      return MaterialPageRoute(builder: (context) => const ProfileScreen());
    case UserInformationScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const UserInformationScreen());
    case PrivacySettingsScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const PrivacySettingsScreen());
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
          builder: (context) => OTPScreen(
                verificationId: verificationId,
              ));
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final uid = arguments['uid'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(
                uid: uid,
              ));

    case LockedChatsScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LockedChatsScreen());
    case DeepfakeDataScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const DeepfakeDataScreen());
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
                body: ErrorScreen(error: "This page doesn't exists"),
              ));
  }
}

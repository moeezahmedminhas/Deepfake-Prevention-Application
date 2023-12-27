import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/utils/colors.dart';
import 'common/widgets/error.dart';
import 'features/authentication/repository/auth_respository.dart';
import 'features/landing/screens/landing_screen.dart';
import 'features/landing/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     debug: true,
  //     ignoreSsl:
  //         true // option: set to false to disable working with http links (default: false)
  //     );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deepfake Prevention Application',
      themeMode: ThemeMode.system,
      // theme: ThemeData.light().copyWith(
      //   // useMaterial3: true,
      //   scaffoldBackgroundColor: backgroundColor,
      //   appBarTheme: const AppBarTheme(
      //     color: primaryColor,
      //   ),
      //   primaryColor: primaryColor,

      // ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: primaryColor,
        ),
        primaryColor: primaryColor,
      ),

      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
          data: (user) {
            if (user == null) {
              return const LandingScreen();
            }
            return const SplashScreen();
          },
          error: (err, trace) {
            return ErrorScreen(error: err.toString());
          },
          loading: () => const Scaffold(
                backgroundColor: Colors.white,
              )),
    );
  }
}

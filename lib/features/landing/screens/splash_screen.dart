import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/colors.dart';
import 'main_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Deepfake Prevention App',
              style: TextStyle(
                  fontFamily: 'Prociono',
                  fontSize: screenSize.height * 0.03,
                  color: primaryColor),
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: Image.asset(
                'assets/backgroundImage.png',
                width: screenSize.width * 0.65, //144.61
                height: screenSize.height * 0.4, //195.73
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Text(
              "To Keep You Safe!",
              style: TextStyle(
                  fontFamily: 'Prociono',
                  fontSize: screenSize.height * 0.02,
                  color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

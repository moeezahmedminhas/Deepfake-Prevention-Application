import 'package:deepfake_prevention_app/common/utils/utils.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            error,
            style: textStyle,
          ),
        ));
  }
}

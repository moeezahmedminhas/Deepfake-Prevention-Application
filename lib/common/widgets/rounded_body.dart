import 'package:flutter/material.dart';

import '../utils/colors.dart';

class RoundedBody extends StatelessWidget {
  final Widget child;

  const RoundedBody({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            )),
        child: child,
      ),
    );
  }
}

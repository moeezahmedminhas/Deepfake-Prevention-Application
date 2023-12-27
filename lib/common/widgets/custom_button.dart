// import 'package:flutter/material.dart';

// import '../utils/colors.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   const CustomButton({
//     Key? key,
//     required this.text,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryColor,
//         minimumSize: const Size(double.infinity, 50),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
import 'package:deepfake_prevention_app/common/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      height: screenSize.height * 0.055,
      width: double.infinity,
      margin: EdgeInsets.only(
          top: screenSize.height * 0.02, bottom: screenSize.height * 0.03),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

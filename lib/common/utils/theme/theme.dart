import 'package:flutter/material.dart';

import '../colors.dart';
import 'custom_themes/text_theme.dart';

class MAppTheme {
  MAppTheme._();
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      color: appBarColor,
    ),
    brightness: Brightness.light,
    primaryColor: Colors.purple,
    textTheme: MTextTheme.lightTextTheme,
  );
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      color: appBarColor,
    ),
    brightness: Brightness.dark,
    primaryColor: Colors.purple,
    textTheme: MTextTheme.darkTextTheme,
  );
}

import 'package:flutter/material.dart';

ThemeData appTheme(Color accentColor) {
  return ThemeData(
    colorScheme: ColorScheme.dark(
      surface: Colors.black,
      primary: Colors.grey,
      secondary: accentColor,
      tertiary: Colors.grey,
      inversePrimary: accentColor,
    ),
    fontFamily: 'PixelifySans',
  );
}
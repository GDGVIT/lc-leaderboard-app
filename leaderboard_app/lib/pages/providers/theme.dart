import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    surface: Colors.black,         // background containers
    primary: Colors.grey,          // text & icons
    secondary: Colors.amber,       // buttons, highlights
    tertiary: Colors.grey,         // progress bar track, muted UI
    inversePrimary: Colors.amber,  // badge/gold accent
  ),
  fontFamily: 'PixelifySans',
);
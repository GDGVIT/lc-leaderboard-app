import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default dark theme configuration
  final ThemeData _themeData = ThemeData(
    colorScheme: const ColorScheme.dark(
      surface: Colors.black,         // background containers
      primary: Colors.grey,          // text & icons
      secondary:Color(0xFFF6C156),       // buttons, highlights
      tertiary: Colors.grey,         // progress bar track, muted UI
      inversePrimary: Color(0xFFF6C156),  // badge/gold accent
    ),
    fontFamily: 'PixelifySans',
  );

  ThemeData get themeData => _themeData;
}
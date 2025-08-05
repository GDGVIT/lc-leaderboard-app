import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider() : _themeData = _buildTheme(Colors.amber); // default

  ThemeData get themeData => _themeData;

  void setThemeColor(Color accent) {
    _themeData = _buildTheme(accent);
    notifyListeners();
  }

  static ThemeData _buildTheme(Color accent) {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        surface: Colors.black,
        primary: Colors.grey,
        secondary: accent,
        tertiary: Colors.grey,
        inversePrimary: accent,
      ),
      fontFamily: 'PixelifySans',
    );
  }
}
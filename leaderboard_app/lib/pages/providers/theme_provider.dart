import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/providers/theme.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeData _themeData = appTheme;

  ThemeData get themeData => _themeData;
}

import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/home_page.dart';
import 'package:leaderboard_app/pages/signup_page.dart';
import 'package:leaderboard_app/pages/signin_page.dart';
import 'package:leaderboard_app/provider/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const HomePage(),
    );
  }
}
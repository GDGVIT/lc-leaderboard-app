import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/home_page.dart';
import 'package:leaderboard_app/pages/signup_page.dart';
import 'package:leaderboard_app/pages/signin_page.dart';
import 'package:leaderboard_app/pages/providers/theme_provider.dart';
import 'package:leaderboard_app/pages/providers/chat_provider.dart'; // 👈 Make sure this is the correct path
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()), // 👈 Added
      ],
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
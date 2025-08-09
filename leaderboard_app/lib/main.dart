import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/home_page.dart';
import 'package:leaderboard_app/pages/signup_page.dart';
import 'package:leaderboard_app/pages/signin_page.dart';
import 'package:leaderboard_app/provider/chatlists_provider.dart';
import 'package:leaderboard_app/provider/chat_provider.dart';
import 'package:leaderboard_app/provider/theme_provider.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => ChatListProvider()..loadDummyGroups(),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Add ChatProvider here
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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
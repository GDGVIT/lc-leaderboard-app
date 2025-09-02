import 'package:flutter/material.dart';
import 'package:leaderboard_app/provider/chatlists_provider.dart';
import 'package:leaderboard_app/provider/chat_provider.dart';
import 'package:leaderboard_app/provider/theme_provider.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:leaderboard_app/router/app_router.dart';
import 'package:leaderboard_app/services/auth/auth_service.dart';
import 'package:leaderboard_app/services/dashboard/dashboard_service.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context) {
  return FutureBuilder(
      future: Future.wait([
        AuthService.create(),
        DashboardService.create(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        final authService = snapshot.data![0] as AuthService;
        final dashboardService = snapshot.data![1] as DashboardService;
  final router = createRouter();

  return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ChatListProvider()..loadDummyGroups()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            Provider.value(value: authService),
            Provider.value(value: dashboardService),
          ],
    child: MainApp(router: router),
        );
      },
    );
  }
}

class MainApp extends StatelessWidget {
  final GoRouter router;
  const MainApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      routerConfig: router,
    );
  }
}
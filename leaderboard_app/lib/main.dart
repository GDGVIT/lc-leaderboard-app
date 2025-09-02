import 'package:flutter/material.dart';
import 'package:leaderboard_app/provider/chatlists_provider.dart';
import 'package:leaderboard_app/provider/chat_provider.dart';
import 'package:leaderboard_app/provider/theme_provider.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:leaderboard_app/router/app_router.dart';
import 'package:leaderboard_app/services/auth/auth_service.dart';
import 'package:leaderboard_app/services/dashboard/dashboard_service.dart';
import 'package:leaderboard_app/services/leetcode/leetcode_service.dart';
import 'package:leaderboard_app/services/groups/group_service.dart';
import 'package:leaderboard_app/services/user/user_service.dart';
import 'package:go_router/go_router.dart';
import 'package:leaderboard_app/provider/group_provider.dart';
import 'package:leaderboard_app/provider/dashboard_provider.dart';

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
        LeetCodeService.create(),
        GroupService.create(),
        UserService.create(),
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
  final leetCodeService = snapshot.data![2] as LeetCodeService;
  final groupService = snapshot.data![3] as GroupService;
  final userService = snapshot.data![4] as UserService;
  final router = createRouter();

  return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ChatListProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            ChangeNotifierProvider(create: (ctx) => GroupProvider(groupService)),
            ChangeNotifierProvider(create: (ctx) => DashboardProvider(service: dashboardService, userProvider: ctx.read<UserProvider>())),
            Provider.value(value: authService),
            Provider.value(value: dashboardService),
            Provider.value(value: leetCodeService),
            Provider.value(value: groupService),
            Provider.value(value: userService),
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
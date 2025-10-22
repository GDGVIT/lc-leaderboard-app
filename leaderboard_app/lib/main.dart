import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:leeterboard/provider/chatlists_provider.dart';
import 'package:leeterboard/provider/chat_provider.dart';
import 'package:leeterboard/provider/theme_provider.dart';
import 'package:leeterboard/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:leeterboard/router/app_router.dart';
import 'package:leeterboard/services/auth/auth_service.dart';
import 'package:leeterboard/services/dashboard/dashboard_service.dart';
import 'package:leeterboard/services/leetcode/leetcode_service.dart';
import 'package:leeterboard/services/groups/group_service.dart';
import 'package:leeterboard/services/user/user_service.dart';
import 'package:go_router/go_router.dart';
import 'package:leeterboard/provider/group_provider.dart';
import 'package:leeterboard/provider/dashboard_provider.dart';
import 'package:leeterboard/provider/group_membership_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leeterboard/provider/connectivity_provider.dart';
import 'package:leeterboard/pages/no_internet_page.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const Bootstrap());
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bootstrapServices(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final data = snapshot.data!;
        final authService = data.authService;
        final dashboardService = data.dashboardService;
        final leetCodeService = data.leetCodeService;
        final groupService = data.groupService;
        final userService = data.userService;
        final router = createRouter();

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ChatListProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
            ChangeNotifierProvider(
              create: (ctx) => GroupProvider(groupService),
            ),
            ChangeNotifierProvider(
              create: (ctx) => DashboardProvider(
                service: dashboardService,
                userProvider: ctx.read<UserProvider>(),
                userService: userService,
              ),
            ),
            ChangeNotifierProvider(
              create: (ctx) => GroupMembershipProvider(
                service: groupService,
                userProvider: ctx.read<UserProvider>(),
              ),
            ),
            Provider.value(value: authService),
            Provider.value(value: dashboardService),
            Provider.value(value: leetCodeService),
            Provider.value(value: groupService),
            Provider.value(value: userService),
          ],
          child: _AppInitializer(router: router),
        );
      },
    );
  }
}

class _BootstrapData {
  final AuthService authService;
  final DashboardService dashboardService;
  final LeetCodeService leetCodeService;
  final GroupService groupService;
  final UserService userService;
  _BootstrapData({
    required this.authService,
    required this.dashboardService,
    required this.leetCodeService,
    required this.groupService,
    required this.userService,
  });
}

Future<_BootstrapData> _bootstrapServices() async {
  final results = await Future.wait([
    AuthService.create(),
    DashboardService.create(),
    LeetCodeService.create(),
    GroupService.create(),
    UserService.create(),
  ]);
  return _BootstrapData(
    authService: results[0] as AuthService,
    dashboardService: results[1] as DashboardService,
    leetCodeService: results[2] as LeetCodeService,
    groupService: results[3] as GroupService,
    userService: results[4] as UserService,
  );
}

class _AppInitializer extends StatefulWidget {
  final GoRouter router;
  const _AppInitializer({required this.router});

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _ready = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // If not logged in, skip any data preload and go straight to router
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    if (token.isEmpty) {
      if (mounted) {
        setState(() => _ready = true);
        FlutterNativeSplash.remove();
      }
      return;
    }

    final connectivity = context.read<ConnectivityProvider>();
    // Wait a tick for connectivity to initialize
    await Future.delayed(const Duration(milliseconds: 50));
    _offline = !connectivity.isOnline;
    if (!_offline) {
      await _preload();
    }
    if (mounted) {
      setState(() {
        _ready = true;
      });
      FlutterNativeSplash.remove();
    }
    // Listen for connectivity changes to leave offline screen automatically
    connectivity.addListener(() async {
      if (mounted && _offline && connectivity.isOnline) {
        setState(() {
          _offline = false;
          _ready = false; // show loading while we fetch
        });
        await _preload();
        if (mounted) {
          setState(() {
            _ready = true;
          });
        }
      }
    });
  }

  Future<void> _preload() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    if (token.isEmpty) {
      // Not logged in; nothing to preload.
      return;
    }
    final returning = prefs.getBool('returningUser') ?? false;
    final userProvider = context.read<UserProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final userService = context.read<UserService>();

    // Always fetch profile if logged in (token check can happen in router later but we attempt anyway)
    try {
      await userProvider.fetchProfile(userService);
    } catch (_) {}

    if (returning) {
      try {
        await dashboardProvider.loadAll();
      } catch (_) {}
    }

    // Mark as returning after first launch completion
    if (!returning) {
      await prefs.setBool('returningUser', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();
    if (!connectivity.isOnline || _offline) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NoInternetPage(),
      );
    }
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MainApp(router: widget.router);
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

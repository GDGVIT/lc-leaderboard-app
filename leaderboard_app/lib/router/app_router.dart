import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:leaderboard_app/pages/home_page.dart';
import 'package:leaderboard_app/pages/signin_page.dart';
import 'package:leaderboard_app/pages/signup_page.dart';
import 'package:leaderboard_app/pages/leetcode_verification_page.dart';
import 'package:leaderboard_app/pages/chat_gate.dart';

Future<bool> _isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  return token != null && token.isNotEmpty;
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/signin',
    refreshListenable: _RouterRefresh(),
    redirect: (context, state) async {
      final loggedIn = await _isLoggedIn();
      final atAuth = state.matchedLocation == '/signin' || state.matchedLocation == '/signup';
  if (!loggedIn && !atAuth) return '/signin';
  if (loggedIn && atAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) => const LeetCodeVerificationPage(),
      ),
      GoRoute(
        path: '/chat/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId'] ?? '';
          final name = state.uri.queryParameters['name'];
          return ChatGate(groupId: groupId, groupName: name);
        },
      ),
    ],
  );
}

// A simple ChangeNotifier to trigger router refresh on auth changes
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh() {
    // no-op. In a real app you could listen to auth provider.
  }
}

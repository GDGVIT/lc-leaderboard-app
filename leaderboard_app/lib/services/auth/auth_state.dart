enum AuthStatus { loggedIn, loggedOut }

class AuthState {
  final AuthStatus status;

  AuthState({required this.status});

  bool get isLoggedIn => status == AuthStatus.loggedIn;
  bool get isLoggedOut => status == AuthStatus.loggedOut;
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:leeterboard/services/auth/auth_service.dart';
import 'package:leeterboard/provider/user_provider.dart';
import 'package:leeterboard/services/user/user_service.dart';
import 'package:leeterboard/provider/chat_provider.dart';
import 'package:leeterboard/provider/chatlists_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // trigger profile fetch if not yet
    final up = context.watch<UserProvider>();
    if (up.user == null && !up.isLoading && up.error == null) {
      // fire and forget
      final svc = context.read<UserService>();
      up.fetchProfile(svc);
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 24,
          ),
          children: [
            // Title with SVG icon (match Chats styling)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: SvgPicture.asset(
                    'assets/icons/LL_Logo.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ====== Personal Details ======
            Text(
              'My Account',
              style: TextStyle(
                color: colors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            Consumer<UserProvider>(
              builder: (context, user, _) {
                // We no longer display separate first/last name fields – just show the full username.
                final name = (user.name).trim();
                final username = name.isNotEmpty ? name : '-';
                final email = (user.email).isNotEmpty ? user.email : '-';
                final streak = user.streak;
                final handle = user.user?.leetcodeHandle;
                final verified = user.user?.leetcodeVerified == true;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: colors.tertiary.withOpacity(0.3),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Username
                      _buildDisplayTile('Username', '@$username', colors),
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: colors.primary.withOpacity(0.3),
                      ),
                      _buildDisplayTile('Email', email, colors),
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: colors.primary.withOpacity(0.3),
                      ),
                      _buildDisplayTile('Streak', streak.toString(), colors),
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: colors.primary.withOpacity(0.3),
                      ),
                      SizedBox(height: 12),
                      // LeetCode handle & verify section
                      if (verified)
                        _buildDisplayTile('LeetCode', handle ?? '-', colors)
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LeetCode',
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.tertiary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      handle ?? 'Not linked',
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  // Navigate to the dedicated verification page used in signup/login flow
                                  onPressed: () => context.push('/verify'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.secondary,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('Verify'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      SizedBox(height: 12),
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: colors.primary.withOpacity(0.3),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 25),
            // Removed password & authentication section per request

            // ====== Logout button (full-width) ======
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Log out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  // Clear auth token + any persisted data
                  await context.read<AuthService>().logout();
                  // Reset in-memory chat state so previous session messages/groups disappear
                  try {
                    context.read<ChatProvider>().reset();
                    context.read<ChatListProvider>().reset();
                  } catch (_) {}
                  if (!context.mounted) return;
                  context.go('/signin');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed in-dialog verification flow; navigation now uses dedicated page '/verify'

  // Label outside, grey pill only around value
  Widget _buildDisplayTile(String title, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: colors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

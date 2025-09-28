import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leaderboard_app/services/auth/auth_service.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:leaderboard_app/services/user/user_service.dart';
import 'package:leaderboard_app/services/leetcode/leetcode_service.dart';
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
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 0,
        foregroundColor: colors.primary,
      ),
  body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ====== Personal Details ======
          Text(
            'My Account',
            style: TextStyle(color: Colors.white, fontSize: 16),
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
                    radius: 40,
                    backgroundColor: colors.tertiary.withOpacity(0.3),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: colors.primary.withOpacity(0.3),
                ),

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
                // LeetCode handle & verify section
                if (verified)
                  _buildDisplayTile('LeetCode', handle ?? '-', colors)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LeetCode',
                        style: TextStyle(color: colors.onSurface, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: colors.tertiary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(handle ?? 'Not linked', style: TextStyle(color: colors.primary, fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showLeetCodeVerifyDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.secondary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            child: const Text('Verify'),
                          ),
                        ],
                      ),
                    ],
                  ),
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

          // ====== Container 2 ======
          Text(
            'Password and Authentication',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.tertiary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDisplayTile('Password', '••••••••', colors)),
                    const SizedBox(width: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.secondary,
                          foregroundColor: colors.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Change password',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account removal',
                    style: TextStyle(color: colors.primary, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.tertiary.withOpacity(0.5),
                        foregroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Disable Account'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Keep red for danger
                        foregroundColor: colors.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Delete Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20), // Extra space above the bottom

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
                await context.read<AuthService>().logout();
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
    );
  }

  Future<void> _showLeetCodeVerifyDialog(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final handleCtrl = TextEditingController();
    String? code;
    String? instructions;
    bool loading = false;
    bool started = false;
    bool polling = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: !loading,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Verify LeetCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!started) ...[
                TextField(
                  controller: handleCtrl,
                  decoration: const InputDecoration(labelText: 'LeetCode Username'),
                ),
                const SizedBox(height: 12),
                if (error != null) Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ] else ...[
                if (instructions != null) Text(instructions!, style: const TextStyle(fontSize: 13)),
                if (code != null) ...[
                  const SizedBox(height: 12),
                  SelectableText('Verification Code: $code', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Add this code to your LeetCode profile bio then keep this dialog open.'),
                ],
                if (polling) ...[
                  const SizedBox(height: 16),
                  Row(children: const [SizedBox(width:16,height:16, child: CircularProgressIndicator(strokeWidth:2)), SizedBox(width:8), Text('Checking status...')]),
                ],
              ],
            ],
          ),
          actions: [
            if (!loading)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            if (!started)
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        final handle = handleCtrl.text.trim();
                        if (handle.isEmpty) {
                          setState(() => error = 'Enter a username');
                          return;
                        }
                        setState(() {
                          loading = true;
                          error = null;
                        });
                        try {
                          final svc = ctx.read<LeetCodeService>();
                          final res = await svc.startVerification(handle);
                          code = res.verificationCode;
                          instructions = res.instructions ?? 'Place the code in your LeetCode bio.';
                          started = true;
                          // begin polling
                          polling = true;
                          setState(() {});
                          _pollLeetCodeStatus(ctx, setState);
                        } catch (e) {
                          error = 'Failed to start verification';
                        } finally {
                          loading = false;
                          setState(() {});
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: colors.secondary, foregroundColor: Colors.black),
                child: const Text('Start'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pollLeetCodeStatus(BuildContext dialogContext, void Function(void Function()) setState) async {
    final svc = dialogContext.read<LeetCodeService>();
    for (int i = 0; i < 30; i++) { // up to ~30 polls
      await Future.delayed(const Duration(seconds: 4));
      try {
        final status = await svc.getStatus();
        if (status.isVerified) {
          // update user provider
            dialogContext.read<UserProvider>().setLeetCodeStatus(handle: status.leetcodeHandle, verified: true);
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
          return;
        }
      } catch (_) {
        // ignore transient errors
      }
      // refresh UI each loop
      setState(() {});
    }
  }

  // Label outside, grey pill only around value
  Widget _buildDisplayTile(String title, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: colors.onSurface, fontSize: 12, fontWeight: FontWeight.w500),
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
              style: TextStyle(color: colors.primary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
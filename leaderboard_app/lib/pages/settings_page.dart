import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leaderboard_app/services/auth/auth_service.dart';
import 'package:leaderboard_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Settings'),
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
            style: TextStyle(color: colors.primary, fontSize: 16),
          ),
          const SizedBox(height: 10),

          Consumer<UserProvider>(
            builder: (context, user, _) {
              final name = (user.name).trim();
              final parts = name.split(RegExp(r"\s+"));
              final firstName = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : '-';
              final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
              final username = name.isNotEmpty ? name : '-';
              final email = (user.email).isNotEmpty ? user.email : '-';
              final streak = user.streak;

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
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colors.tertiary.withOpacity(0.3),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Edit",
                          style: TextStyle(color: colors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: colors.primary.withOpacity(0.3),
                ),

                // First & Last Name side-by-side
                Row(
                  children: [
                    Expanded(child: _buildDisplayTile('First Name', firstName, colors)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDisplayTile('Last Name', lastName.isEmpty ? '-' : lastName, colors)),
                  ],
                ),
                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: colors.primary.withOpacity(0.3),
                ),
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
              ],
            ),
          );
            },
          ),

          const SizedBox(height: 25),

          // ====== Container 2 ======
          Text(
            'Password and Authentication',
            style: TextStyle(color: colors.primary, fontSize: 16),
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
                    ElevatedButton(
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

  // Non-editable display tile
  Widget _buildDisplayTile(String title, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.tertiary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: colors.primary.withOpacity(0.7), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: colors.primary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
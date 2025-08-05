import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== Personal Details ======
          const Text(
            'My Account',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                const Divider(
                  height: 1,
                  thickness: 0.6,
                  indent: 0,
                  endIndent: 0,
                  color: Color.fromARGB(179, 158, 158, 158),
                ),

                // First & Last Name side-by-side
                Row(
                  children: [
                    Expanded(child: _buildDisplayTile('First Name', 'Penny')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDisplayTile('Last Name', 'Valeria')),
                  ],
                ),
                const Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Color.fromARGB(179, 158, 158, 158),
                ),
                _buildDisplayTile('Username', '@pennyval'),
                const Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Color.fromARGB(179, 158, 158, 158),
                ),
                _buildDisplayTile('Email', 'penny@example.com'),
                const Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Color.fromARGB(179, 158, 158, 158),
                ),
                _buildDisplayTile('Phone Number', '+91 1234567890'),
                const Divider(
                  height: 1,
                  thickness: 0.6,
                  color: Color.fromARGB(179, 158, 158, 158),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====== Container 2 ======
          const Text(
            'Password and Authentication',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDisplayTile('Password', '••••••••')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account removal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
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
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
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

          const SizedBox(height: 25),

          // ====== Container 3 ======
          const Text(
            'Appearance',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a preferred theme for the website',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildThemeDot(context, Colors.pink),
                    _buildThemeDot(context, Colors.red),
                    _buildThemeDot(context, Colors.green),
                    _buildThemeDot(context, Colors.teal),
                    _buildThemeDot(context, Colors.amber),
                    _buildThemeDot(context, Colors.blueAccent),
                    _buildThemeDot(context, Colors.white),
                    _buildThemeDot(context, Colors.deepPurpleAccent),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 100), // Extra space above the bottom
        ],
      ),
    );
  }

  // Non-editable display tile
  Widget _buildDisplayTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDot(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        final themeProvider = Provider.of<ThemeProvider>(
          context,
          listen: false,
        );
        themeProvider.setThemeColor(color);
      },
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

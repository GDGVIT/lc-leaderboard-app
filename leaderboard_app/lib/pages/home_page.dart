import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/dashboard_page.dart';
import 'package:leaderboard_app/pages/chatlists_page.dart';
import 'package:leaderboard_app/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    ChatlistsPage(),
    Center(child: Text("Stats Page", style: TextStyle(color: Colors.white))),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey[900],
          primaryColor: Colors.yellow,
          textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: const TextStyle(color: Colors.white),
              ),
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore, size: 28),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: 28),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, size: 28),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 28),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:leaderboard_app/pages/files_page.dart';
import 'package:leaderboard_app/pages/media_page.dart';
import 'package:pie_chart/pie_chart.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.inversePrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Duel Now!"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Avatar
            const CircleAvatar(radius: 50, backgroundColor: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              "Penny Valeria",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 16),

            // Info Tiles
            _infoTile(Icons.people, "Friends for:", "3 Months"),
            _infoTile(
              Icons.star,
              "Rank:",
              "Gold",
              trailingIcon: Icons.star,
              trailingColor: Colors.amber,
            ),
            _infoTile(Icons.send, "Currently on:", "Title 1"),

            const SizedBox(height: 16),

            // Duel Stats
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Number of Duels:",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  PieChart(
                    dataMap: const {"Penny": 6, "You": 10},
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 16,
                    chartRadius: 120,
                    colorList: [Colors.grey.shade800, Colors.amber],
                    chartType: ChartType.ring,
                    ringStrokeWidth: 28,
                    legendOptions: const LegendOptions(
                      showLegends: true,
                      legendTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      legendPosition: LegendPosition.left,
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValues: false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bottom Tiles
            _bottomTile(context, "Media", "192"),
            _bottomTile(context, "Files", "193"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value, {
    IconData? trailingIcon,
    Color? trailingColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: trailingColor ?? Colors.white, size: 18),
          if (trailingIcon == null)
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _bottomTile(BuildContext context, String title, String count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade900,
      ),
      child: Material(
        color:
            Colors.transparent, // So the original container color shows through
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12), // Same radius to clip ripple
          onTap: () {
            if (title == "Media") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MediaPage()),
              );
            } else if (title == "Files") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FilesPage()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Text(
                  count,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
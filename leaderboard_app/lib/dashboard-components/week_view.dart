import 'package:flutter/material.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  late final int todayIndex;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    todayIndex = now.weekday % 7; // DateTime.weekday: Mon=1..Sun=7, so mod 7 gives Sun=0..Sat=6
    _scrollController = ScrollController();

    // Wait for the first frame then scroll to the current day
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double position = todayIndex * 72.0; // approx item width (60 + margin 12)
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String dateText = "${_monthName(now.month)} ${now.day}, ${now.year}";

    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              dateText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                bool isToday = index == todayIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 60,
                  decoration: BoxDecoration(
                    color: isToday ? Colors.amber : Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(height: 4),
                      Text(
                        days[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
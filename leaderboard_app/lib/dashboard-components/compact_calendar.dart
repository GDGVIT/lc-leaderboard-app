import 'package:flutter/material.dart';

class CompactCalendar extends StatefulWidget {
  const CompactCalendar({super.key});

  @override
  State<CompactCalendar> createState() => _CompactCalendarState();
}

class _CompactCalendarState extends State<CompactCalendar> {
  DateTime _selectedDate = DateTime.now();

  final List<String> _months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final List<String> _weekdays = const [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  final List<int> _years = List.generate(50, (i) => 2000 + i); // 2000–2049

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    int year = _selectedDate.year;
    int month = _selectedDate.month;

    DateTime firstOfMonth = DateTime(year, month, 1);
    int weekdayOffset = firstOfMonth.weekday == 7 ? 0 : firstOfMonth.weekday;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    List<Widget> dayWidgets = [];

    // Blank slots before the month starts
    for (int i = 1; i < weekdayOffset; i++) {
      dayWidgets.add(Container());
    }

    // Day buttons
    for (int i = 1; i <= daysInMonth; i++) {
      dayWidgets.add(
        Container(
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: i == _selectedDate.day ? colors.secondary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            "$i",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month + Year dropdowns
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                dropdownColor: Colors.grey[850],
                value: month,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(_months[index]),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDate = DateTime(year, val, 1);
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                dropdownColor: Colors.grey[850],
                value: year,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: _years.map((yr) {
                  return DropdownMenuItem(value: yr, child: Text(yr.toString()));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDate = DateTime(val, month, 1);
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
      
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            }).toList(),
          ),
      
          const SizedBox(height: 6),
      
          // Calendar grid
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 7,
            children: dayWidgets,
          ),
        ],
      ),
    );
  }
}
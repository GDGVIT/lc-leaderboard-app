import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider extends ChangeNotifier {
  String name = "First Name Last Name";
  String email = "username@email.com";
  int streak = 4;

  void updateStreak(int newStreak) {
    streak = newStreak;
    notifyListeners();
  }

  void updateUser({required String newName, required String newEmail}) {
    name = newName;
    email = newEmail;
    notifyListeners();
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth < 400
                ? constraints.maxWidth
                : 400;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: Colors.grey[900],
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.black),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildHeaderButton(
                            Icons.local_fire_department,
                            "${user.streak}",
                            Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderButton(
                            Icons.person_add,
                            "Invite",
                            Colors.amber,
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCard(
                              child: Column(
                                children: [
                                  const Center(
                                    child: Text(
                                      'June 5, 2025',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 80,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 7,
                                      itemBuilder: (context, index) {
                                        const days = [
                                          'Sun',
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                        ];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          width: 60,
                                          decoration: BoxDecoration(
                                            color: index == 4
                                                ? Colors.amber
                                                : Colors.grey[900],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                days[index],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            _buildCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "10. Regular Expression Matching",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: 0.4,
                                    color: Colors.amber,
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[700],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        "Resume >",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            _buildCard(
                              child: DataTable(
                                columnSpacing: 10,
                                dataRowMinHeight: 32,
                                dataRowMaxHeight: 36,
                                headingRowHeight: 32,
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey[900],
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "Place",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Player",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Streak",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Solved",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Badge",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(
                                  5,
                                  (index) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          "${index + 1}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          "Player ${index + 1}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const DataCell(
                                        Text(
                                          "12",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const DataCell(
                                        Text(
                                          "1324",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const DataCell(
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            const SizedBox(height: 8),
                            _buildCard(
                              child: DataTable(
                                columnSpacing: 10,
                                dataRowMinHeight: 32,
                                dataRowMaxHeight: 36,
                                headingRowHeight: 32,
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey[900],
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "No.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Title",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Acc.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Lvl",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Prog",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(
                                  4,
                                  (index) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          "${index + 1}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const DataCell(
                                        Text(
                                          "Problem",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const DataCell(
                                        Text(
                                          "56%",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const DataCell(
                                        Text(
                                          "Easy",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const DataCell(
                                        Icon(
                                          Icons.circle,
                                          color: Colors.green,
                                          size: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            _buildCard(
                              child: Column(
                                children: [
                                  Center(
                                    child: Text(
                                      "This Week",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  _buildBar("Easy", 0.8, Colors.green),
                                  const SizedBox(height: 6),
                                  _buildBar("Medium", 0.4, Colors.amber),
                                  const SizedBox(height: 6),
                                  _buildBar("Hard", 0.2, Colors.red),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            _buildCard(child: _CompactCalendar()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildHeaderButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  static Widget _buildBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: Colors.white24,
          ),
        ),
      ],
    );
  }

  static Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _CompactCalendar extends StatefulWidget {
  @override
  State<_CompactCalendar> createState() => _CompactCalendarState();
}

class _CompactCalendarState extends State<_CompactCalendar> {
  DateTime _selectedDate = DateTime.now();

  List<String> _months = const [
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

  List<String> _weekdays = const [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  List<int> _years = List.generate(50, (i) => 2000 + i); // 2000–2049

  @override
  Widget build(BuildContext context) {
    int year = _selectedDate.year;
    int month = _selectedDate.month;

    DateTime firstOfMonth = DateTime(year, month, 1);
    int weekdayOffset = firstOfMonth.weekday == 7
        ? 0
        : firstOfMonth.weekday; // Monday = 1
    int daysInMonth = DateTime(year, month + 1, 0).day;

    List<Widget> dayWidgets = [];

    // Blank slots before month start
    for (int i = 1; i < weekdayOffset; i++) {
      dayWidgets.add(Container());
    }

    // Days of month
    for (int i = 1; i <= daysInMonth; i++) {
      dayWidgets.add(
        Container(
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: i == _selectedDate.day ? Colors.amber : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text("$i", style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month + Year dropdown row
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
    );
  }
}
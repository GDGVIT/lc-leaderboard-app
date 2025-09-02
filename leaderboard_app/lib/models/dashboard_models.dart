class SubmissionItem {
  final String title;
  final String titleSlug;
  final String statusDisplay;
  final String lang;
  final double acRate;
  final String difficulty;
  final DateTime timestamp;

  SubmissionItem({
    required this.title,
    required this.titleSlug,
    required this.statusDisplay,
    required this.lang,
    required this.acRate,
    required this.difficulty,
    required this.timestamp,
  });

  factory SubmissionItem.fromJson(Map<String, dynamic> json) => SubmissionItem(
        title: json['title'] ?? '',
        titleSlug: json['titleSlug'] ?? '',
        statusDisplay: json['statusDisplay'] ?? '',
        lang: json['lang'] ?? '',
        acRate: (json['acRate'] ?? 0).toDouble(),
        difficulty: json['difficulty'] ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['timestamp']?.toString() ?? '0')! * 1000,
          isUtc: true,
        ),
      );
}

class DailyQuestion {
  final String questionLink;
  final String questionTitle;
  final String difficulty;
  final DateTime date;

  DailyQuestion({
    required this.questionLink,
    required this.questionTitle,
    required this.difficulty,
    required this.date,
  });

  factory DailyQuestion.fromJson(Map<String, dynamic> json) => DailyQuestion(
        questionLink: json['questionLink'] ?? '',
        questionTitle: json['questionTitle'] ?? '',
        difficulty: json['difficulty'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );
}

class TopUser {
  final String username;
  final int streak;
  final int totalSolved;

  TopUser({required this.username, required this.streak, required this.totalSolved});

  factory TopUser.fromJson(Map<String, dynamic> json) => TopUser(
        username: json['username'] ?? '',
        streak: (json['streak'] ?? 0) as int,
        totalSolved: (json['totalSolved'] ?? 0) as int,
      );
}

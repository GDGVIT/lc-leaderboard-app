import 'dashboard_models.dart';

class SubmissionsResponse {
  final bool success;
  final String message;
  final DateTime timestamp;
  final SubmissionData data;

  SubmissionsResponse({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  factory SubmissionsResponse.fromJson(Map<String, dynamic> json) => SubmissionsResponse(
        success: json['success'] == true || json['ok'] == true,
        message: json['message']?.toString() ?? '',
        timestamp: _parseTimestamp(json['timestamp']),
        data: SubmissionData.fromJson((json['data'] ?? json) as Map<String, dynamic>),
      );

  static DateTime _parseTimestamp(dynamic ts) {
    if (ts == null) return DateTime.now();
    if (ts is int) {
      // assume ms if large, else seconds
      if (ts > 2000000000) return DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true);
      return DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
    }
    if (ts is String) {
      final i = int.tryParse(ts);
      if (i != null) return _parseTimestamp(i);
      return DateTime.tryParse(ts) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class SubmissionData {
  final List<SubmissionEntry> submissions;
  final int count;
  final int limit;

  SubmissionData({
    required this.submissions,
    required this.count,
    required this.limit,
  });

  factory SubmissionData.fromJson(Map<String, dynamic> json) {
    final raw = json['submissions'] ?? json['items'] ?? json['results'];
    final list = raw is List ? raw : <dynamic>[];
    return SubmissionData(
      submissions: list.map((e) => SubmissionEntry.fromJson(e as Map<String, dynamic>)).toList(),
      count: (json['count'] ?? list.length) as int,
      limit: (json['limit'] ?? list.length) as int,
    );
  }
}

class SubmissionEntry {
  final String title;
  final String titleSlug;
  final String timestamp; // keep raw for reference
  final StatusDisplay statusDisplay;
  final Lang lang;
  final double acRate;
  final Difficulty difficulty;

  SubmissionEntry({
    required this.title,
    required this.titleSlug,
    required this.timestamp,
    required this.statusDisplay,
    required this.lang,
    required this.acRate,
    required this.difficulty,
  });

  factory SubmissionEntry.fromJson(Map<String, dynamic> json) => SubmissionEntry(
        title: json['title']?.toString() ?? '',
        titleSlug: json['titleSlug']?.toString() ?? '',
        timestamp: json['timestamp']?.toString() ?? '0',
        statusDisplay: _parseStatus(json['statusDisplay']),
        lang: _parseLang(json['lang']),
        acRate: (json['acRate'] ?? 0).toDouble(),
        difficulty: _parseDifficulty(json['difficulty']),
      );

  SubmissionItem toSubmissionItem() => SubmissionItem(
        title: title,
        titleSlug: titleSlug,
        statusDisplay: statusDisplay.name.toLowerCase(),
        lang: lang.name.toLowerCase(),
        acRate: acRate,
        difficulty: difficulty.name.toLowerCase(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(timestamp) != null ? int.parse(timestamp) * 1000 : 0,
          isUtc: true,
        ),
      );

  static StatusDisplay _parseStatus(dynamic v) {
    final s = v?.toString().toLowerCase();
    if (s == 'accepted' || s == 'ac') return StatusDisplay.ACCEPTED;
    return StatusDisplay.ACCEPTED; // only one variant currently
  }

  static Lang _parseLang(dynamic v) {
    final s = v?.toString().toLowerCase();
    if (s == 'python3' || s == 'python') return Lang.PYTHON3;
    return Lang.PYTHON3; // default
  }

  static Difficulty _parseDifficulty(dynamic v) {
    final s = v?.toString().toLowerCase();
    if (s == 'easy') return Difficulty.EASY;
    if (s == 'medium') return Difficulty.MEDIUM;
    if (s == 'hard') return Difficulty.HARD;
    return Difficulty.EASY;
  }
}

enum Difficulty { EASY, HARD, MEDIUM }
enum Lang { PYTHON3 }
enum StatusDisplay { ACCEPTED }

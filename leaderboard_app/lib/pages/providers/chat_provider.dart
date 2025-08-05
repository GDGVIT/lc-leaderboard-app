import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final String currentUserId = "uid_me";

  final List<Map<String, dynamic>> _messages = [
    {"senderID": "uid_me", "type": "image", "timestamp": "12:34 pm"},
    {
      "senderID": "uid_me",
      "message": "Hello! How’s your prep going?",
      "timestamp": "12:34 pm",
    },
    {
      "senderID": "system",
      "message": "Duelled",
      "timestamp": "12:34 pm",
      "icon": Icons.bolt,
    },
    {
      "senderID": "uid_1",
      "message": "Pretty good! Yours?",
      "timestamp": "12:35 pm",
    },
  ];

  List<Map<String, dynamic>> get messages => _messages;

  String? _replyTo;
  String? get replyTo => _replyTo;

  bool get hasReply => _replyTo != null;

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    _messages.add({
      "senderID": currentUserId,
      "message": message.trim(),
      "timestamp": _getFormattedTime(),
      if (_replyTo != null) "replyTo": _replyTo,
    });

    _replyTo = null;
    notifyListeners();
  }

  void setReplyTo(String? message) {
    _replyTo = message;
    notifyListeners();
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'pm' : 'am';
    return "$hour:$minute $period";
  }
}
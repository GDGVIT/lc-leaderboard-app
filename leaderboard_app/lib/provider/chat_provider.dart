import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class ChatProvider extends ChangeNotifier {
  final String receiverID;
  final String currentUserID = "uid_me";

  ChatProvider({required this.receiverID});

  final List<Map<String, dynamic>> _messages = [
    {"senderID": "uid_me", "type": "image", "timestamp": "12:34 pm"},
    {
      "senderID": "uid_me",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:34 pm",
    },
    {
      "senderID": "system",
      "message": "Duelled",
      "timestamp": "12:34 pm",
      "icon": Pixel.bullseye,
    },
    {
      "senderID": "uid_1",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:35 pm",
    },
    {
      "senderID": "uid_me",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:35 pm",
    },
    {
      "senderID": "uid_1",
      "message": "text text text text text text text text text text...",
      "timestamp": "12:35 pm",
    },
  ];

  List<Map<String, dynamic>> get messages => _messages;

  String? _replyTo;
  String? get replyTo => _replyTo;

  bool _showAttachmentOptions = false;
  bool get showAttachmentOptions => _showAttachmentOptions;

  /// Send a new message
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messages.add({
      "senderID": currentUserID,
      "message": text.trim(),
      "timestamp": "now",
      if (_replyTo != null) "replyTo": _replyTo,
    });

    _replyTo = null;
    notifyListeners();
  }

  /// Set reply-to target
  void setReplyTo(String? message) {
    _replyTo = message;
    notifyListeners();
  }

  /// Clear reply-to state
  void clearReplyTo() {
    _replyTo = null;
    notifyListeners();
  }

  /// Toggle attachment options visibility
  void toggleAttachmentOptions() {
    _showAttachmentOptions = !_showAttachmentOptions;
    notifyListeners();
  }
}
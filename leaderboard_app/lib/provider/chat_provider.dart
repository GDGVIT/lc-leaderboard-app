import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class ChatProvider extends ChangeNotifier {
  final String currentUserID = "uid_me";

  /// Stores messages per group: { groupId: [messageMap, ...] }
  final Map<String, List<Map<String, dynamic>>> _groupMessages = {};

  /// Stores replyTo per group
  final Map<String, String?> _groupReplyTo = {};

  /// Stores attachment options visibility per group
  final Map<String, bool> _groupAttachmentVisibility = {};

  /// Define some users with colors
  final List<Map<String, dynamic>> _dummyUsers = [
    {"id": "uid_me", "name": "You", "color": Colors.black},
    {"id": "uid_1", "name": "Person 1", "color": Colors.purple},
    {"id": "uid_2", "name": "Person 2", "color": Colors.red},
    {"id": "uid_3", "name": "Person 3", "color": Colors.green},
    {"id": "uid_4", "name": "Person 4", "color": Colors.blue},
  ];

  /// Get messages for a specific group
  List<Map<String, dynamic>> getMessages(String groupId) =>
      _groupMessages[groupId] ?? [];

  /// Helper to get user info
  Map<String, dynamic> _getUser(String id) =>
      _dummyUsers.firstWhere((u) => u["id"] == id);

  /// Initialize a group with dummy messages
  void _initGroupIfNeeded(String groupId) {
    _groupMessages.putIfAbsent(groupId, () => [
          {
            "senderID": "uid_1",
            "senderName": _getUser("uid_1")["name"],
            "senderColor": _getUser("uid_1")["color"],
            "message": "text text text text text text text text text text...",
            "timestamp": "12:30 pm",
          },
          {
            "senderID": "uid_1",
            "senderName": _getUser("uid_1")["name"],
            "senderColor": _getUser("uid_1")["color"],
            "message": "text text text text text text text text text text...",
            "timestamp": "12:31 pm",
          },
          {
            "senderID": "uid_2",
            "senderName": _getUser("uid_2")["name"],
            "senderColor": _getUser("uid_2")["color"],
            "message": "text text text text text text text text text text...",
            "timestamp": "12:33 pm",
          },
          {
            "senderID": currentUserID,
            "senderName": _getUser(currentUserID)["name"],
            "senderColor": _getUser(currentUserID)["color"],
            "message": "text text text text text text text text text text...",
            "timestamp": "12:34 pm",
          },
          {
            "senderID": "uid_3",
            "senderName": _getUser("uid_3")["name"],
            "senderColor": _getUser("uid_3")["color"],
            "message": "text text text text text text text text text text...",
            "timestamp": "12:35 pm",
          },
          {
            "senderID": "uid_4",
            "senderName": _getUser("uid_4")["name"],
            "senderColor": _getUser("uid_4")["color"],
            "message": "text text text text text text text text text text...",
            "timestamp": "12:36 pm",
          },
        ]);

    _groupReplyTo.putIfAbsent(groupId, () => null);
    _groupAttachmentVisibility.putIfAbsent(groupId, () => false);
  }

  /// Get reply-to for a specific group
  String? getReplyTo(String groupId) {
    _initGroupIfNeeded(groupId);
    return _groupReplyTo[groupId];
  }

  /// Get attachment options state for a specific group
  bool getAttachmentOptionsVisibility(String groupId) {
    _initGroupIfNeeded(groupId);
    return _groupAttachmentVisibility[groupId] ?? false;
  }

  /// Send a new message in a group
  void sendMessage(String groupId, String text) {
    if (text.trim().isEmpty) return;

    _initGroupIfNeeded(groupId);
    final user = _getUser(currentUserID);

    _groupMessages[groupId]!.add({
      "senderID": currentUserID,
      "senderName": user["name"],
      "senderColor": user["color"],
      "message": text.trim(),
      "timestamp": "now",
      if (_groupReplyTo[groupId] != null) "replyTo": _groupReplyTo[groupId],
    });

    _groupReplyTo[groupId] = null;
    notifyListeners();
  }

  /// Set reply-to target for a group
  void setReplyTo(String groupId, String? message) {
    _initGroupIfNeeded(groupId);
    _groupReplyTo[groupId] = message;
    notifyListeners();
  }

  /// Clear reply-to state for a group
  void clearReplyTo(String groupId) {
    _initGroupIfNeeded(groupId);
    _groupReplyTo[groupId] = null;
    notifyListeners();
  }

  /// Toggle attachment options for a group
  void toggleAttachmentOptions(String groupId) {
    _initGroupIfNeeded(groupId);
    _groupAttachmentVisibility[groupId] =
        !(_groupAttachmentVisibility[groupId] ?? false);
    notifyListeners();
  }
}
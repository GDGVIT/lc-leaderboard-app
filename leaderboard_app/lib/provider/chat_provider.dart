import 'package:flutter/material.dart';

/// Local-only ChatProvider: keeps in-memory messages per group. Navigation
/// logic (direct-to-chat if member) remains intact, but no realtime backend.
class ChatProvider extends ChangeNotifier {
  final String currentUserID = 'local_me';

  final Map<String, List<Map<String, dynamic>>> _groupMessages = {};
  final Map<String, String?> _groupReplyTo = {};
  final Map<String, bool> _groupAttachmentVisibility = {};
  final Set<String> _joinedGroups = {};

  // Exposed connection flags (kept for UI compatibility; always "connected").
  bool get isConnecting => false;
  bool get isConnected => true;
  String? get connectionError => null;

  List<Map<String, dynamic>> getMessages(String groupId) => _groupMessages[groupId] ?? const [];
  String? getReplyTo(String groupId) => _groupReplyTo[groupId];
  bool getAttachmentOptionsVisibility(String groupId) => _groupAttachmentVisibility[groupId] ?? false;

  Future<void> joinGroup(BuildContext context, String groupId) async {
    if (_joinedGroups.contains(groupId)) return;
    _joinedGroups.add(groupId);
    _groupMessages.putIfAbsent(groupId, () => []);
    _groupReplyTo.putIfAbsent(groupId, () => null);
    _groupAttachmentVisibility.putIfAbsent(groupId, () => false);
  }

  void sendMessage(String groupId, String text) {
    if (text.trim().isEmpty) return;
    if (!_joinedGroups.contains(groupId)) joinGroup(null as dynamic, groupId); // ensure initialized
    final list = (_groupMessages[groupId] ??= []);
    list.add({
      'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
      'groupId': groupId,
      'message': text.trim(),
      'timestamp': _formatTimestamp(DateTime.now()),
      'senderID': currentUserID,
      'senderName': 'You',
      'senderColor': Colors.black,
      if (_groupReplyTo[groupId] != null) 'replyTo': _groupReplyTo[groupId],
    });
    _groupReplyTo[groupId] = null;
    notifyListeners();
  }

  void setReplyTo(String groupId, String? message) {
    _groupReplyTo[groupId] = message;
    notifyListeners();
  }
  void clearReplyTo(String groupId) {
    _groupReplyTo[groupId] = null;
    notifyListeners();
  }
  void toggleAttachmentOptions(String groupId) {
    _groupAttachmentVisibility[groupId] = !(_groupAttachmentVisibility[groupId] ?? false);
    notifyListeners();
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$h:$m $ampm';
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leaderboard_app/models/chat_message.dart';
import 'package:leaderboard_app/services/chat/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

/// ChatProvider integrates REST history + Socket.IO realtime events.
class ChatProvider extends ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _groupMessages = {};
  final Map<String, String?> _groupReplyTo = {};
  final Map<String, bool> _groupAttachmentVisibility = {};
  final Set<String> _joinedGroups = {};
  final Map<String, int> _groupCurrentPage = {}; // page loaded so far (starts at 1)
  final Map<String, bool> _groupHasMore = {}; // whether more pages available
  bool isLoadingMore(String groupId) => _loadingMoreGroups.contains(groupId);
  final Set<String> _loadingMoreGroups = {};

  StreamSubscription<ChatMessage>? _sub;

  bool _connecting = false;
  bool _connected = false;
  String? _connError;
  String? _currentUserId;
  String? _currentUsername;
  void Function(String groupId)? onIncomingMessage; // UI hook for auto-scroll

  // Public getters
  bool get isConnecting => _connecting;
  bool get isConnected => _connected;
  String? get connectionError => _connError;
  String get currentUserID => _currentUserId ?? '';
  String get currentUsername => _currentUsername ?? '';

  List<Map<String, dynamic>> getMessages(String groupId) => _groupMessages[groupId] ?? const [];
  String? getReplyTo(String groupId) => _groupReplyTo[groupId];
  bool getAttachmentOptionsVisibility(String groupId) => _groupAttachmentVisibility[groupId] ?? false;

  Future<void> initIfNeeded([BuildContext? context]) async {
    if (_currentUserId != null) return;
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _currentUsername = prefs.getString('username') ?? prefs.getString('name');
    if ((_currentUserId == null || _currentUsername == null) && context != null) {
      try {
        final userProv = context.read<UserProvider>();
        if (_currentUserId == null) _currentUserId = userProv.user?.id;
        if (_currentUsername == null) _currentUsername = userProv.user?.username;
      } catch (_) {}
    }
    _currentUserId ??= 'me';
    _currentUsername ??= 'You';
    // ignore: avoid_print
    print('[CHAT] init userId=$_currentUserId username=$_currentUsername');
  }

  Future<void> _ensureSocket() async {
    if (_connected || _connecting) return;
    _connecting = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    try {
      await ChatService.instance.ensureConnected(authToken: token);
      _connected = true;
      _connError = null;
      _sub ??= ChatService.instance.messagesStream.listen(_handleIncomingMessage);
    } catch (e) {
      _connError = e.toString();
    } finally {
      _connecting = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(BuildContext context, String groupId) async {
    await initIfNeeded(context);
    await _ensureSocket();
    if (_joinedGroups.contains(groupId)) return;
    _joinedGroups.add(groupId);
    _groupMessages.putIfAbsent(groupId, () => []);
    _groupReplyTo.putIfAbsent(groupId, () => null);
    _groupAttachmentVisibility.putIfAbsent(groupId, () => false);

    // Fetch history (page=1)
    try {
      final history = await ChatService.instance.fetchHistory(groupId, page: 1);
      final mapped = history.map(_toMap).toList();
      _groupMessages[groupId] = mapped;
      _groupCurrentPage[groupId] = 1;
      _groupHasMore[groupId] = history.length >= 50; // heuristic based on limit
    } catch (e) {
      // Optionally add a system message
      _groupMessages[groupId]?.add({
        'id': 'err-${DateTime.now().millisecondsSinceEpoch}',
        'groupId': groupId,
        'message': 'Failed to load history: $e',
        'timestamp': _formatTimestamp(DateTime.now()),
        'senderID': 'system',
        'senderName': 'System',
      });
    }
    // Join via socket after history
    ChatService.instance.joinGroup(groupId);
    // debug log
    // ignore: avoid_print
    print('[CHAT] joinGroup requested for $groupId');
    notifyListeners();
  }

  Future<void> sendMessage(String groupId, String text) async {
    if (text.trim().isEmpty) return;
    final trimmed = text.trim();
    final ok = await ChatService.instance.sendMessage(
      groupId,
      trimmed,
      sender: {
        'id': currentUserID,
        'username': 'You',
      },
    );
    if (!ok) {
      // Append a system error message (optional)
      final list = (_groupMessages[groupId] ??= []);
      list.add({
        'id': 'err-${DateTime.now().microsecondsSinceEpoch}',
        'groupId': groupId,
        'message': 'Failed to send message.',
        'timestamp': _formatTimestamp(DateTime.now()),
        'senderID': 'system',
        'senderName': 'System',
        'senderColor': Colors.red,
      });
      notifyListeners();
    }
  }

  Future<void> loadMore(String groupId) async {
    if (!(_groupHasMore[groupId] ?? false)) return;
    if (_loadingMoreGroups.contains(groupId)) return;
    final next = (_groupCurrentPage[groupId] ?? 1) + 1;
    _loadingMoreGroups.add(groupId);
    notifyListeners();
    try {
      final history = await ChatService.instance.fetchHistory(groupId, page: next);
      if (history.isEmpty) {
        _groupHasMore[groupId] = false;
      } else {
        final list = _groupMessages[groupId] ??= [];
        final existingIds = list.map((e) => e['id']).toSet();
        final newOnes = history.where((m) => !existingIds.contains(m.id)).map(_toMap);
        list.insertAll(0, newOnes); // prepend older messages
        _groupCurrentPage[groupId] = next;
        _groupHasMore[groupId] = history.length >= 50;
      }
    } catch (_) {
      // swallow or add a system message if desired
    } finally {
      _loadingMoreGroups.remove(groupId);
      notifyListeners();
    }
  }

  void _handleIncomingMessage(ChatMessage m) {
    final list = (_groupMessages[m.groupId] ??= []);
    // Dedupe exact id
    if (list.any((e) => e['id'] == m.id)) return;
    list.add(_toMap(m));
    notifyListeners();
    // Trigger UI callback after listeners update
    try {
      onIncomingMessage?.call(m.groupId);
    } catch (_) {}
  }

  Map<String, dynamic> _toMap(ChatMessage m) {
    final bool isMe = (m.senderId.isNotEmpty && m.senderId == currentUserID) ||
        (m.senderName.toLowerCase() == currentUsername.toLowerCase());
    // ignore: avoid_print
    print('[CHAT] map message id=${m.id} senderId=${m.senderId} senderName=${m.senderName} isMe=$isMe currentUser=$currentUserID/$currentUsername');
    return {
      'id': m.id,
      'groupId': m.groupId,
      'message': m.message,
      'timestamp': _formatTimestamp(m.timestamp),
      'senderID': m.senderId,
      'senderName': isMe ? 'You' : m.senderName,
      'senderColor': isMe ? Colors.black : Colors.white,
      'isMe': isMe,
      if (m.replyTo != null) 'replyTo': m.replyTo,
    };
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

  @override
  void dispose() {
    _sub?.cancel();
    ChatService.instance.dispose();
    super.dispose();
  }
}
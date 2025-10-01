import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:leaderboard_app/config/api_config.dart';
import 'package:leaderboard_app/services/core/dio_provider.dart';
import 'package:leaderboard_app/models/chat_message.dart';
import 'package:leaderboard_app/models/chat_message_dto.dart';

typedef MessageHandler = void Function(ChatMessage message);

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  io.Socket? _socket;
  bool get isConnected => _socket?.connected == true;
  bool _connecting = false;
  bool get isConnecting => _connecting;
  String? lastError;

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messagesStream => _messageController.stream;

  /// Establish the socket connection (idempotent). Provide [authToken] for
  /// backend auth if required.
  Future<void> ensureConnected({String? authToken}) async {
    if (isConnected || _connecting) return;
    _connecting = true;
    lastError = null;
  final base = ApiConfig.baseUrl; // e.g. http://host:port/api
  final wsBase = base.replaceFirst('/api', '');
    try {
      final socket = io.io(wsBase, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        // Backend guide: JWT via auth.token
        if (authToken != null) 'auth': {'token': authToken},
      });
      final completer = Completer<void>();
      socket.on('connect', (_) {
        // Basic event logging hook
        socket.onAny((event, data) {
          // ignore: avoid_print
          print('[SOCKET] event=$event data=${data is Map ? data.keys : data}');
        });
        completer.complete();
      });
      socket.on('connect_error', (err) {
        lastError = err.toString();
        if (!completer.isCompleted) completer.completeError(err);
      });
      // Server → Client: receive_message
      socket.on('receive_message', (data) {
        if (data is Map) {
          try {
            final msg = ChatMessage.fromSocket(_normalizeSocketPayload(Map<String, dynamic>.from(data)));
            _messageController.add(msg);
          } catch (e) {
            // ignore
          }
        }
      });
      // Joined group ack: add minimal log
      socket.on('joined_group', (d) => print('[SOCKET] joined_group: $d'));
      socket.on('error', (e) => print('[SOCKET] server_error: $e'));
      socket.connect();
      _socket = socket;
      await completer.future.timeout(const Duration(seconds: 8));
    } catch (e) {
      lastError = e.toString();
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  Map<String, dynamic> _normalizeSocketPayload(Map<String, dynamic> raw) {
    // Backend receive_message: { id, groupId, message, sender, timestamp }
    if (raw.containsKey('content') && !raw.containsKey('message')) {
      raw['message'] = raw['content'];
    }
    if (raw.containsKey('createdAt') && !raw.containsKey('timestamp')) {
      raw['timestamp'] = raw['createdAt'];
    }
    // Ensure sender structure
    if (raw['sender'] is! Map) {
      final id = raw['senderId'] ?? raw['senderID'];
      raw['sender'] = {
        'id': id,
        'username': raw['senderName'] ?? 'User',
      };
    }
    return raw;
  }

  /// Ask server to subscribe to a group's room for realtime events.
  void joinGroup(String groupId) {
    if (!isConnected) return;
    // Guide: join_group expects groupId as raw string, not object
    _socket?.emit('join_group', groupId);
  }

  /// Emit a message to server (server should broadcast back with `message:new`).
  Future<bool> sendMessage(String groupId, String text, {Map<String, dynamic>? sender}) async {
    if (text.trim().isEmpty) return false;
    if (!isConnected) return false;
    final payload = {
      'groupId': groupId,
      'message': text.trim(),
      if (sender != null) 'sender': sender,
    };
    try {
      // Backend does not specify ack; emit fire-and-forget.
      _socket?.emit('send_message', payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve paginated message history using the documented REST endpoint.
  Future<List<ChatMessage>> fetchHistory(String groupId, {int page = 1, int limit = 50}) async {
    final dio = await DioProvider.getInstance();
    final res = await dio.get('/messages/groups/$groupId', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final data = res.data;
    final list = (data['data']?['messages'] ?? []) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList();
  }

  void dispose() {
    _messageController.close();
    _socket?.dispose();
  }
}
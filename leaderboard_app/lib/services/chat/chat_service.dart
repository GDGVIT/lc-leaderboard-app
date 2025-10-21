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
        _attachCommonListeners(socket);
        completer.complete();
      });
      socket.on('connect_error', (err) {
        lastError = err.toString();
        if (!completer.isCompleted) completer.completeError(err);
      });
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
    if (text.trim().isEmpty) {
      // ignore: avoid_print
      print('[SOCKET][SEND] Abort: empty text');
      return false;
    }
    if (!isConnected) {
      // ignore: avoid_print
      print('[SOCKET][SEND] Not connected. Attempting lazy connect before send...');
      try {
        // We cannot fetch token here directly; higher layer ensures ensureConnected.
        // If still disconnected after this, fail.
      } catch (e) {
        // ignore: avoid_print
        print('[SOCKET][SEND] Lazy connect exception: $e');
      }
      if (!isConnected) {
        // ignore: avoid_print
        print('[SOCKET][SEND] Fail: socket still not connected');
        return false;
      }
    }
    final payload = {
      'groupId': groupId,
      'message': text.trim(),
      if (sender != null) 'sender': sender,
    };
    try {
      // Backend does not specify ack; emit fire-and-forget.
      // ignore: avoid_print
      print('[SOCKET][SEND] Emitting send_message payloadKeys=${payload.keys}');
      _socket?.emit('send_message', payload);
      return true;
    } catch (err) {
      // ignore: avoid_print
      print('[SOCKET][SEND] Exception while emitting: $err');
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

  /// Explicitly disconnect socket (without closing stream) for logout so that
  /// a subsequent login can establish a fresh authenticated connection.
  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
  }

  /// Force a brand-new socket connection using the supplied JWT. This should
  /// be called immediately after a successful login to ensure the socket
  /// authenticates as the new user and does not reuse prior connection state.
  Future<void> connectWithToken(String jwt, {List<String> rejoinGroupIds = const []}) async {
    // Tear down any existing connection fully.
    disconnect();
    lastError = null;
    _connecting = true;
    final base = ApiConfig.baseUrl;
    final wsBase = base.replaceFirst('/api', '');
    try {
      final socket = io.io(wsBase, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'forceNew': true, // ensure a new engine.io session
        'auth': {'token': jwt},
      });
      final completer = Completer<void>();
      socket.on('connect', (_) {
        // ignore: avoid_print
        print('[SOCKET] Connected (forceNew)');
        _attachCommonListeners(socket);
        // Rejoin prior groups if provided
        for (final gid in rejoinGroupIds) {
          socket.emit('join_group', gid);
        }
        completer.complete();
      });
      socket.on('connect_error', (err) {
        lastError = err.toString();
        if (!completer.isCompleted) completer.completeError(err);
      });
      _socket = socket;
      socket.connect();
      await completer.future.timeout(const Duration(seconds: 8));
    } catch (e) {
      lastError = e.toString();
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  /// Attach listeners common to both normal and forceNew connections.
  void _attachCommonListeners(io.Socket socket) {
    // Generic event tracer.
    socket.onAny((event, data) {
      // ignore: avoid_print
      print('[SOCKET][EVENT] $event');
    });
    // Detailed receive logging.
    socket.on('receive_message', (data) {
      // ignore: avoid_print
      print('[SOCKET][RECEIVE] raw=${data.runtimeType} -> $data');
      if (data is Map) {
        try {
          final msg = ChatMessage.fromSocket(_normalizeSocketPayload(Map<String, dynamic>.from(data)));
          _messageController.add(msg);
        } catch (e) {
          // ignore: avoid_print
          print('[SOCKET][RECEIVE] parse error: $e');
        }
      } else {
        // ignore: avoid_print
        print('[SOCKET][RECEIVE] unexpected payload type; ignoring');
      }
    });
    socket.on('joined_group', (d) {
      // ignore: avoid_print
      print('[SOCKET] joined_group: $d');
    });
    socket.on('error', (e) {
      // ignore: avoid_print
      print('[SOCKET] server_error: $e');
    });
  }
}
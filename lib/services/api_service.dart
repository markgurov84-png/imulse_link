import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiService {
  static const String baseUrl = 'https://75k5nn-5-189-59-95.ru.tuna.am';
  late IO.Socket socket;
  bool isConnected = false;

  void initSocket(int userId) {
    try {
      socket = IO.io(baseUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build());
      
      socket.connect();
      
      socket.on('connect', (_) {
        print('Socket connected');
        isConnected = true;
        socket.emit('user-online', userId);
      });
      
      socket.on('disconnect', (_) {
        print('Socket disconnected');
        isConnected = false;
      });
      
      socket.on('connect_error', (error) {
        print('Socket error: $error');
        isConnected = false;
      });
    } catch (e) {
      print('Init socket error: $e');
      isConnected = false;
    }
  }

  void disconnectSocket() {
    if (isConnected) {
      socket.disconnect();
      socket.dispose();
      isConnected = false;
    }
  }

  // Auth
  Future<Map<String, dynamic>> sendCode(String email, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'username': username, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'users': []};
    }
  }

  // Chats
  Future<Map<String, dynamic>> getChats(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chats/$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'chats': []};
    }
  }

  Future<Map<String, dynamic>> getOrCreateChat(int userId, int otherUserId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chats'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'otherUserId': otherUserId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> getMessages(String chatId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/messages/$chatId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'messages': []};
    }
  }

  void sendMessage(int fromUserId, int toUserId, String text, {String type = 'text', String? mediaUrl}) {
    if (!isConnected) {
      print('Socket not connected!');
      return;
    }
    try {
      socket.emit('send-message', {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'text': text,
        'type': type,
        'mediaUrl': mediaUrl,
      });
    } catch (e) {
      print('Send message error: $e');
    }
  }

  void sendTyping(int fromUserId, int toUserId, bool isTyping) {
    if (!isConnected) return;
    try {
      socket.emit('typing', {'fromUserId': fromUserId, 'toUserId': toUserId, 'isTyping': isTyping});
    } catch (e) {
      print('Typing error: $e');
    }
  }

  void markRead(String chatId, int userId) {
    if (!isConnected) return;
    try {
      socket.emit('mark-read', {'chatId': chatId, 'userId': userId});
    } catch (e) {
      print('Mark read error: $e');
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    if (!isConnected) return;
    socket.on('new-message', callback);
  }

  void onMessageSent(Function(dynamic) callback) {
    if (!isConnected) return;
    socket.on('message-sent', callback);
  }

  void onUserTyping(Function(dynamic) callback) {
    if (!isConnected) return;
    socket.on('user-typing', callback);
  }

  void onUserStatusChanged(Function(dynamic) callback) {
    if (!isConnected) return;
    socket.on('user-status-changed', callback);
  }

  void onMessagesRead(Function(dynamic) callback) {
    if (!isConnected) return;
    socket.on('messages-read', callback);
  }

  // Posts
  Future<Map<String, dynamic>> createPost(int userId, String username, String avatar, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'username': username, 'avatar': avatar, 'text': text}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> getPosts(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/posts?userId=$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'posts': []};
    }
  }

  Future<Map<String, dynamic>> getSavedPosts(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/saved-posts?userId=$userId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'posts': []};
    }
  }

  Future<Map<String, dynamic>> toggleLike(int postId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'postId': postId, 'userId': userId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleSave(int postId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'postId': postId, 'userId': userId}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> addComment(int postId, int userId, String username, String avatar, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/comment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'postId': postId, 'userId': userId, 'username': username, 'avatar': avatar, 'text': text}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: $e'};
    }
  }

  Future<Map<String, dynamic>> getComments(int postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/comments?postId=$postId'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'comments': []};
    }
  }
}
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> otherUser;
  final int currentUserId;
  final String currentUsername;
  final String currentAvatar;
  final ApiService api;

  ChatScreen({
    required this.chatId,
    required this.otherUser,
    required this.currentUserId,
    required this.currentUsername,
    required this.currentAvatar,
    required this.api,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  bool _isTyping = false;
  bool _otherUserTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    widget.api.onNewMessage((data) {
      if (data['chatId'] == widget.chatId) {
        setState(() {
          _messages.add(data['message']);
        });
        widget.api.markRead(widget.chatId, widget.currentUserId);
      }
    });

    widget.api.onMessageSent((data) {
      if (data['chatId'] == widget.chatId) {
        setState(() {
          _messages.add(data['message']);
        });
      }
    });

    widget.api.onUserTyping((data) {
      if (data['fromUserId'] == widget.otherUser['id']) {
        setState(() {
          _otherUserTyping = data['isTyping'];
        });
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final response = await widget.api.getMessages(widget.chatId);
    if (response['success'] == true) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(response['messages']);
        _isLoading = false;
      });
      widget.api.markRead(widget.chatId, widget.currentUserId);
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    widget.api.sendMessage(
      widget.currentUserId,
      widget.otherUser['id'],
      _messageController.text,
    );
    _messageController.clear();
    _sendTyping(false);
  }

  void _sendTyping(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      widget.api.sendTyping(widget.currentUserId, widget.otherUser['id'], typing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF007AFF),
              child: Text(
                widget.otherUser['avatar'] ?? widget.otherUser['username'][0].toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUser['username'], style: TextStyle(fontSize: 16)),
                if (_otherUserTyping)
                  Text('печатает...', style: TextStyle(fontSize: 12, color: Color(0xFF007AFF)))
                else if (widget.otherUser['online'] == true)
                  Text('в сети', style: TextStyle(fontSize: 12, color: Colors.green))
                else
                  Text('не в сети', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB0))),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)))
                : _messages.isEmpty
                    ? Center(child: Text('Нет сообщений', style: TextStyle(color: Color(0xFF8A9BB0))))
                    : ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[_messages.length - 1 - index];
                          final isMe = message['fromUserId'] == widget.currentUserId;
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8, left: isMe ? 40 : 0, right: isMe ? 0 : 40),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['text'] ?? '',
              style: TextStyle(color: isMe ? Colors.white : Color(0xFF1A2C3E)),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message['time']),
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Color(0xFF8A9BB0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (text) => _sendTyping(text.isNotEmpty),
              decoration: InputDecoration(
                hintText: 'Сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFF5F7FA),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF007AFF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeStr) {
    final time = DateTime.parse(timeStr);
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inHours < 1) return '${diff.inMinutes} мин';
    if (diff.inDays < 1) return '${diff.inHours} ч';
    return '${diff.inDays} д';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
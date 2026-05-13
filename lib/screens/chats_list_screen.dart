import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chats_screen.dart';

class ChatsListScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String avatar;

  ChatsListScreen({
    required this.userId,
    required this.username,
    required this.avatar,
  });

  @override
  _ChatsListScreenState createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> with SingleTickerProviderStateMixin {
  late ApiService _api;
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _api = ApiService();
    _loadData();
    _tabController = TabController(length: 2, vsync: this);
    
    // Слушаем изменения статуса пользователей
    _api.onUserStatusChanged((data) {
      setState(() {
        _updateUserStatus(data['userId'], data['online']);
      });
    });
  }

  void _updateUserStatus(int userId, bool online) {
    for (var chat in _chats) {
      if (chat['otherUser']['id'] == userId) {
        chat['otherUser']['online'] = online;
      }
    }
    for (var user in _users) {
      if (user['id'] == userId) {
        user['online'] = online;
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final chatsRes = await _api.getChats(widget.userId);
    final usersRes = await _api.getUsers();
    
    if (chatsRes['success'] == true) {
      setState(() => _chats = List<Map<String, dynamic>>.from(chatsRes['chats']));
    }
    if (usersRes['success'] == true) {
      setState(() => _users = List<Map<String, dynamic>>.from(usersRes['users'])
          .where((u) => u['id'] != widget.userId)
          .toList());
    }
    
    setState(() => _isLoading = false);
  }

  void _startChat(Map<String, dynamic> user) async {
    final response = await _api.getOrCreateChat(widget.userId, user['id']);
    if (response['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: response['chat']['id'],
            otherUser: response['chat']['otherUser'],
            currentUserId: widget.userId,
            currentUsername: widget.username,
            currentAvatar: widget.avatar,
            api: _api,
          ),
        ),
      ).then((_) => _loadData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Сообщения', style: TextStyle(color: Color(0xFF1A2C3E))),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF007AFF),
          unselectedLabelColor: Color(0xFF8A9BB0),
          indicatorColor: Color(0xFF007AFF),
          tabs: [
            Tab(text: 'Чаты', icon: Icon(Icons.chat_bubble_outline)),
            Tab(text: 'Пользователи', icon: Icon(Icons.people_outline)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)))
          : TabBarView(
              controller: _tabController,
              children: [
                _chats.isEmpty
                    ? Center(child: Text('Нет чатов', style: TextStyle(color: Color(0xFF8A9BB0))))
                    : ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _chats.length,
                        itemBuilder: (context, index) => _buildChatTile(_chats[index]),
                      ),
                _users.isEmpty
                    ? Center(child: Text('Нет пользователей', style: TextStyle(color: Color(0xFF8A9BB0))))
                    : ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _users.length,
                        itemBuilder: (context, index) => _buildUserTile(_users[index]),
                      ),
              ],
            ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    final otherUser = chat['otherUser'];
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF007AFF),
          radius: 24,
          child: Text(
            otherUser['avatar'] ?? otherUser['username'][0].toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Text(otherUser['username'], style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E))),
            if (otherUser['online'] == true)
              Container(
                margin: EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Text(
          chat['lastMessage'] ?? 'Нет сообщений',
          maxLines: 1,
          style: TextStyle(color: Color(0xFF8A9BB0)),
        ),
        trailing: Text(
          _formatTime(chat['lastTime']),
          style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB0)),
        ),
        onTap: () => _startChat(otherUser),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF007AFF),
          radius: 24,
          child: Text(
            user['avatar'] ?? user['username'][0].toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Text(user['username'], style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E))),
            if (user['online'] == true)
              Container(
                margin: EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Text(
          user['online'] == true ? 'В сети' : 'Был(а) недавно',
          style: TextStyle(color: user['online'] == true ? Colors.green : Color(0xFF8A9BB0)),
        ),
        trailing: Icon(Icons.chat_bubble_outline, color: Color(0xFF007AFF)),
        onTap: () => _startChat(user),
      ),
    );
  }

  String _formatTime(dynamic timeStr) {
    if (timeStr == null) return '';
    try {
      final time = DateTime.parse(timeStr.toString());
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inMinutes < 1) return 'только что';
      if (diff.inHours < 1) return '${diff.inMinutes} мин';
      if (diff.inDays < 1) return '${diff.inHours} ч';
      return '${diff.inDays} д';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> posts = [];
  final TextEditingController _postController = TextEditingController();
  bool isLoading = true;
  int currentUserId = 1;
  String currentUsername = 'current_user';
  String currentAvatar = 'U';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => isLoading = true);
    final response = await _api.getPosts(currentUserId);
    if (response['success'] == true) {
      setState(() {
        posts = List<Map<String, dynamic>>.from(response['posts']);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    final response = await _api.createPost(
      currentUserId,
      currentUsername,
      currentAvatar,
      _postController.text,
    );

    if (response['success'] == true) {
      _postController.clear();
      await _loadPosts();
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = posts[index];
    final response = await _api.toggleLike(post['id'], currentUserId);

    if (response['success'] == true) {
      setState(() {
        posts[index]['isLiked'] = response['isLiked'];
        posts[index]['likesCount'] = response['likesCount'];
      });
    }
  }

  Future<void> _toggleSave(int index) async {
    final post = posts[index];
    final response = await _api.toggleSave(post['id'], currentUserId);

    if (response['success'] == true) {
      setState(() {
        posts[index]['isSaved'] = response['isSaved'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['isSaved'] ? 'Сохранено 📌' : 'Удалено из сохранённых'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showCommentsDialog(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        postId: post['id'],
        api: _api,
        currentUserId: currentUserId,
        currentUsername: currentUsername,
        currentAvatar: currentAvatar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('ImulseLink', style: TextStyle(color: Color(0xFF1A2C3E))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Color(0xFF007AFF)),
            onPressed: () => _showSavedPosts(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPostInput(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF007AFF)))
                : posts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: posts.length,
                        itemBuilder: (context, index) => _buildPostCard(posts[index], index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF007AFF),
            child: Text(currentAvatar, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: 'Что нового?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF8A9BB0)),
              ),
            ),
          ),
          IconButton(
            onPressed: _createPost,
            icon: const Icon(Icons.send, color: Color(0xFF007AFF)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF007AFF),
                  child: Text(post['avatar'] ?? 'U', style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post['username'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2C3E))),
                      Text(_formatTime(post['time']), style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BB0))),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    post['isSaved'] == true ? Icons.bookmark : Icons.bookmark_border,
                    color: const Color(0xFF007AFF),
                  ),
                  onPressed: () => _toggleSave(index),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post['text'], style: const TextStyle(fontSize: 15, color: Color(0xFF1A2C3E))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildActionButton(
                  icon: post['isLiked'] == true ? Icons.favorite : Icons.favorite_border,
                  label: '${post['likesCount'] ?? 0}',
                  color: post['isLiked'] == true ? Colors.red : const Color(0xFF8A9BB0),
                  onTap: () => _toggleLike(index),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post['commentsCount'] ?? 0}',
                  color: const Color(0xFF8A9BB0),
                  onTap: () => _showCommentsDialog(post),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Поделиться',
                  color: const Color(0xFF8A9BB0),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, size: 64, color: Color(0xFF8A9BB0)),
          const SizedBox(height: 16),
          const Text('Нет постов', style: TextStyle(color: Color(0xFF8A9BB0), fontSize: 16)),
          const Text('Напиши первый пост!', style: TextStyle(color: Color(0xFF8A9BB0), fontSize: 14)),
        ],
      ),
    );
  }

  void _showSavedPosts() async {
    final response = await _api.getSavedPosts(currentUserId);
    if (response['success'] == true) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Сохранённые посты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: response['posts'].length,
                  itemBuilder: (context, index) {
                    final post = response['posts'][index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(post['avatar'] ?? 'U')),
                      title: Text(post['username']),
                      subtitle: Text(post['text'], maxLines: 2),
                      trailing: const Icon(Icons.bookmark, color: Color(0xFF007AFF)),
                      onTap: () => Navigator.pop(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inMinutes < 1) return 'только что';
      if (diff.inHours < 1) return '${diff.inMinutes} мин';
      if (diff.inDays < 1) return '${diff.inHours} ч';
      return '${diff.inDays} д';
    } catch (e) {
      return 'недавно';
    }
  }
}

// ========== КОММЕНТАРИИ ==========
class CommentsSheet extends StatefulWidget {
  final int postId;
  final ApiService api;
  final int currentUserId;
  final String currentUsername;
  final String currentAvatar;

  const CommentsSheet({
    Key? key,
    required this.postId,
    required this.api,
    required this.currentUserId,
    required this.currentUsername,
    required this.currentAvatar,
  }) : super(key: key);

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  List<Map<String, dynamic>> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final response = await widget.api.getComments(widget.postId);
    if (response['success'] == true) {
      setState(() {
        comments = List<Map<String, dynamic>>.from(response['comments']);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final response = await widget.api.addComment(
      widget.postId,
      widget.currentUserId,
      widget.currentUsername,
      widget.currentAvatar,
      _commentController.text,
    );

    if (response['success'] == true) {
      _commentController.clear();
      await _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E5EC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Комментарии', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? const Center(child: Text('Нет комментариев', style: TextStyle(color: Color(0xFF8A9BB0))))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFF007AFF),
                                  child: Text(
                                    comment['avatar'] ?? 'U',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(comment['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(comment['text'], style: const TextStyle(fontSize: 14)),
                                      Text(
                                        _formatTime(comment['time']),
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF8A9BB0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF007AFF),
                  child: Text(widget.currentAvatar, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Написать комментарий...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send, color: Color(0xFF007AFF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inMinutes < 1) return 'только что';
      if (diff.inHours < 1) return '${diff.inMinutes} мин';
      if (diff.inDays < 1) return '${diff.inHours} ч';
      return '${diff.inDays} д';
    } catch (e) {
      return 'недавно';
    }
  }
}
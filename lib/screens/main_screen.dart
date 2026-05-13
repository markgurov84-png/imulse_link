import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'chats_list_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final String email;
  final int userId;
  final String avatar;

  const MainScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.userId,
    required this.avatar,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      FeedScreen(),
      ChatsListScreen(
        userId: widget.userId,
        username: widget.username,
        avatar: widget.avatar,
      ),
      ProfileScreen(
        username: widget.username,
        email: widget.email,
        userId: widget.userId,
        avatar: widget.avatar,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: const Color(0xFF8A9BB0),
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Лента',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
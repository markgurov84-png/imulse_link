import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(ImulseLinkApp());
}

class ImulseLinkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImulseLink',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFFF0F4FA),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
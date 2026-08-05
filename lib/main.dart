import 'package:flutter/material.dart';
import './features/auth/login_page.dart';

void main() {
  runApp(const PloggrApp());
}

class PloggrApp extends StatelessWidget {
  const PloggrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

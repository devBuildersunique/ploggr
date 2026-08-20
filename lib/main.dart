import 'package:flutter/material.dart';
import 'package:ploggr/features/auth/login_page.dart';
import 'package:ploggr/features/auth/signup_page.dart';
// import 'package:ploggr/features/home/home_page.dart';
import 'package:ploggr/features/splash/splash_screen.dart';
// import 'package:ploggr/features/leaderboard/leaderboard_page.dart';
// import 'lib';
// import '../';

void main() {
  runApp(const PloggrApp());
}

class PloggrApp extends StatelessWidget {
  const PloggrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      // home: const LoginPage(),
    );
  }
}

// Version system
// major change:: 0.23
// minor + hotfix :: 0.23.x
// 1. major major change

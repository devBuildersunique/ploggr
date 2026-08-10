import 'package:flutter/material.dart';
import 'package:ploggr/features/splash/splash_screen.dart';
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
      // home: const HomePage(),
    );
  }
}

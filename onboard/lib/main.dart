import 'package:flutter/material.dart';
import 'package:onboard/onboard_screen.dart';

void main() {
  runApp(SwiftGymApp());
}

class SwiftGymApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swift Gym',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: OnboardingScreen(), // 👈 yahan se start hoga
    );
  }
}
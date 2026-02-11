import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const HealthyWealthyApp());
}

class HealthyWealthyApp extends StatelessWidget {
  const HealthyWealthyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Wealthy Diet Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lexend',
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6dc57d),
        scaffoldBackgroundColor: const Color(0xFFf6f8f6),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Lexend',
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF42f062),
        scaffoldBackgroundColor: const Color(0xFF102214),
      ),
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'pages/membership_page.dart';
import 'pages/membership_plans.dart';

void main() {
  runApp(const GymSwiftApp());
}

class GymSwiftApp extends StatelessWidget {
  const GymSwiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymSwift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B0F0F)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Named routes
      initialRoute: '/',
      routes: {
        '/': (context) => const MembershipPage(),
        '/plans': (context) => const MembershipPlansPage(),
      },
    );
  }
}
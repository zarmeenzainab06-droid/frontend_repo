import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboard screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? seenOnboard;

  @override
  void initState() {
    super.initState();
    checkOnboarding();
  }

  void checkOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      seenOnboard = prefs.getBool('seenOnboard') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (seenOnboard == null) {
      return MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (seenOnboard ?? false) ? HomeScreen() : OnboardingScreen(),
    );
  }
}

/// Dummy Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swift Gym")),
      body: Center(child: Text("Welcome to Home Screen")),
    );
  }
}
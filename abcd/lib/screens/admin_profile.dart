import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("GymSwift | Admin Panel"),
      ),

      body: Center(
        child: Text("Profile Screen"), // 👈 yahan apna full code paste karo
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/theme.dart';

class MemberTrainerScreen extends StatelessWidget {
  const MemberTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('My Trainer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(
        child: Text(
          'Trainer details coming soon',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
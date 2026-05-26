import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/app_shell.dart';

class MemberDashboard extends StatefulWidget {
  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    final user = GetStorage().read('user');
    _userName = user?['name'] ?? 'Member';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: 'user',
      subtitle: 'Member Portal',
      bottomNav: const MemberBottomNav(activeIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $_userName!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's your fitness journey overview",
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            _placeholderCard(
              'Membership Status',
              Icons.card_membership_outlined,
            ),
            const SizedBox(height: 12),
            _placeholderCard('Next Payment', Icons.attach_money_outlined),
            const SizedBox(height: 12),
            _placeholderCard('Workout Sessions', Icons.fitness_center_outlined),
            const SizedBox(height: 20),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _placeholderCard(
              'Activity will appear here',
              Icons.history_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderCard(String label, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

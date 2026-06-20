import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/theme.dart';
import '../../core/widgets/member_layout.dart';
import 'member_plans_screen.dart';

class MemberDashboard extends StatefulWidget {
  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final box = GetStorage();
  String _userName = '';
  Map<String, dynamic>? _membership;
  Map<String, dynamic>? _trainer;
  Map<String, dynamic>? _dietPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userName = box.read('userName') ?? 'Member';
    _loadDashboardData();
  }

  String _getToken() => box.read('token') ?? '';

  Future<void> _loadDashboardData() async {
    await Future.wait([_loadMembership(), _loadTrainer(), _loadDietPlan()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadMembership() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/members/membership'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _membership = data['membership']);
      }
    } catch (e) {
      print('Membership error: $e');
    }
  }

  Future<void> _loadTrainer() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/members/trainer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _trainer = data['trainer']);
      }
    } catch (e) {
      print('Trainer error: $e');
    }
  }

  Future<void> _loadDietPlan() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/diet/my-plan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _dietPlan = data['diet_plan']);
      }
    } catch (e) {
      print('Diet plan error: $e');
    }
  }

  // Calculate days left
  int _daysLeft() {
    if (_membership == null || _membership!['end_date'] == null) return 0;
    try {
      final endDate = DateTime.parse(_membership!['end_date'].toString());
      return endDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemberLayout(
      currentIndex: 0,
      title: 'Member Portal',
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Top Welcome Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: Color(0xFF6B1A1A)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Plan info row
                        Row(
                          children: [
                            const Icon(
                              Icons.card_membership,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _membership?['package_name'] ?? 'No Plan',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _membership?['end_date'] != null
                                  ? 'Expires ${_membership!['end_date'].toString().substring(0, 10)}'
                                  : 'No expiry',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Trainer: ${_trainer?['name'] ?? 'N/A'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Days left badge
                        Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            children: [
                              Text(
                                '${_daysLeft()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'days left',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Quick Access Buttons
                        const Text(
                          'Quick Access',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _quickButton(
                                'Membership',
                                Icons.card_membership,
                                Colors.blue,
                                () => Get.toNamed('/member_membership'),
                              ),
                              const SizedBox(width: 8),
                              _quickButton(
                                'Trainer',
                                Icons.fitness_center,
                                Colors.purple,
                                () => Get.toNamed('/member_trainer'),
                              ),
                              const SizedBox(width: 8),
                              _quickButton(
                                'Payments',
                                Icons.payment,
                                Colors.green,
                                () => Get.toNamed('/member-payment'),
                              ),
                              const SizedBox(width: 8),
                              _quickButton(
                                'Diet Plan',
                                Icons.restaurant,
                                Colors.orange,
                                () => Get.toNamed('/member-diet'),
                              ),
                              const SizedBox(width: 8),
                              _quickButton(
                                'Profile',
                                Icons.person,
                                Colors.grey[800]!,
                                () => Get.toNamed('/member_profile'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ✅ Next Payment Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [AppTheme.cardShadow],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Next Payment',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rs. ${_membership?['price'] ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Get.toNamed('/member-payment'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ✅ My Diet Plan Card
                        if (_dietPlan != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [AppTheme.cardShadow],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.restaurant,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'My Diet Plan',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.activeLight,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Active',
                                        style: TextStyle(
                                          color: AppTheme.active,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _dietPlan!['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Assigned by ${_trainer?['name'] ?? 'Trainer'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Meal icons row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _mealIcon('🍳', 'Breakfast'),
                                    _mealIcon('☀️', 'Lunch'),
                                    _mealIcon('🌙', 'Dinner'),
                                    _mealIcon('🥤', 'Snacks'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // View full plan button
                                InkWell(
                                  onTap: () => Get.toNamed('/member-diet'),
                                  child: const Center(
                                    child: Text(
                                      'View Full Plan →',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // No diet plan card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [AppTheme.cardShadow],
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.restaurant_outlined,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'No diet plan assigned yet',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Quick access button
  Widget _quickButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Meal icon widget
  Widget _mealIcon(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

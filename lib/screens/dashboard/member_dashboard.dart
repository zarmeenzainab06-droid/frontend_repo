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
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 143, 110, 110),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 16,
                  ), // gap between MemberLayout top bar and welcome card
                  // ✅ Top Welcome Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          HSLColor.fromColor(AppTheme.primary)
                              .withLightness(
                                (HSLColor.fromColor(
                                          AppTheme.primary,
                                        ).lightness -
                                        0.18)
                                    .clamp(0.0, 1.0),
                              )
                              .toColor(),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.30),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _bannerInfoRow(
                              Icons.card_membership,
                              _membership?['package_name'] ?? 'No Plan',
                            ),
                            const SizedBox(height: 6),
                            _bannerInfoRow(
                              Icons.calendar_today,
                              _membership?['end_date'] != null
                                  ? 'Expires ${_membership!['end_date'].toString().substring(0, 10)}'
                                  : 'No expiry',
                            ),
                            const SizedBox(height: 6),
                            _bannerInfoRow(
                              Icons.person,
                              'Trainer: ${_trainer?['name'] ?? 'N/A'}',
                            ),
                            const SizedBox(height: 16),
                            // days left badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_daysLeft()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
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
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                'PKR ${_membership?['price'] ?? '0'}',
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

  Widget _bannerInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
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

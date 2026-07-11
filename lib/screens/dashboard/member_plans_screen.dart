import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/member_layout.dart';

class MemberPlansScreen extends StatefulWidget {
  const MemberPlansScreen({super.key});

  @override
  State<MemberPlansScreen> createState() => _MemberPlansScreenState();
}

class _MemberPlansScreenState extends State<MemberPlansScreen> {
  List<dynamic> _plans = [];
  Map<String, dynamic>? _currentPlan;
  bool _isLoading = true;
  final box = GetStorage();

  String _getToken() => box.read('token') ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadPlans(), _loadCurrentPlan()]);
  }

  // Load all packages from backend
  Future<void> _loadPlans() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/packages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _plans = data['packages'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Load current membership
  Future<void> _loadCurrentPlan() async {
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
        setState(() => _currentPlan = data['membership']);
      }
    } catch (e) {
      print('Current plan error: $e');
    }
  }

  // Calculate days left
  int _daysLeft() {
    if (_currentPlan == null || _currentPlan!['end_date'] == null) return 0;
    try {
      final endDate = DateTime.parse(_currentPlan!['end_date'].toString());
      return endDate.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  // Format date
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return MemberLayout(
      currentIndex: 1,
      title: 'Member Portal',
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Membership Plans',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose the plan that fits your fitness goals',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current Plan Card
                  if (_currentPlan != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3),
                        ),
                        boxShadow: [AppTheme.cardShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Plan header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Plan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentPlan!['status'] == 'active'
                                      ? AppTheme.activeLight
                                      : AppTheme.expiredLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (_currentPlan!['status'] ?? 'inactive')
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: _currentPlan!['status'] == 'active'
                                        ? AppTheme.active
                                        : AppTheme.expired,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Plan details row
                          Row(
                            children: [
                              // Plan name
                              Expanded(
                                child: _currentPlanItem(
                                  Icons.attach_money,
                                  'Plan',
                                  _currentPlan!['package_name'] ?? 'N/A',
                                ),
                              ),
                              // Expiry date
                              Expanded(
                                child: _currentPlanItem(
                                  Icons.calendar_month,
                                  'Expires On',
                                  _formatDate(
                                    _currentPlan!['end_date']?.toString(),
                                  ),
                                ),
                              ),
                              // Days left
                              Expanded(
                                child: _currentPlanItem(
                                  Icons.access_time,
                                  'Days Left',
                                  '${_daysLeft()} Days',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Available Plans heading
                  const Text(
                    'Available Plans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Plans grid - horizontal scroll
                  _plans.isEmpty
                      ? const Center(
                          child: Text(
                            'Koi plan nahi mila',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _plans.map((plan) {
                              // Check if this is current plan
                              final isCurrent =
                                  plan['name'] == _currentPlan?['package_name'];
                              return _buildPlanCard(plan, isCurrent);
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  // Current plan detail item
  Widget _currentPlanItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Single plan card
  Widget _buildPlanCard(Map<String, dynamic> plan, bool isCurrent) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppTheme.primary : AppTheme.border,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          // Most Popular badge
          if (plan['name']?.toString().toLowerCase().contains('premium') ==
              true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Text(
                'Most Popular',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name
                Text(
                  plan['name'] ?? 'Plan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Duration
                Text(
                  '${plan['duration']} days',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Price
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rs.${plan['price']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                      const TextSpan(
                        text: ' /total',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Description features
                if (plan['description'] != null)
                  ...(plan['description'] as String)
                      .split(',')
                      .take(3)
                      .map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.active,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  feature.trim(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                const SizedBox(height: 12),

                // Choose / Renew button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        isCurrent ? 'Renew Plan' : 'Plan Selected',
                        '${plan['name']} ${isCurrent ? 'renew' : 'selected'}! Admin se contact karo.',
                        backgroundColor: AppTheme.activeLight,
                        colorText: AppTheme.active,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? AppTheme.primary
                          : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isCurrent ? 'Renew Plan' : 'Choose Plan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

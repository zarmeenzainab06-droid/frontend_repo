import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/theme.dart';
import '../../core/services/member_service.dart';

class MemberMembershipScreen extends StatefulWidget {
  const MemberMembershipScreen({super.key});

  @override
  State<MemberMembershipScreen> createState() =>
      _MemberMembershipScreenState();
}

class _MemberMembershipScreenState extends State<MemberMembershipScreen> {
  Map<String, dynamic>? _membership;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembership();
  }

  Future<void> _loadMembership() async {
    setState(() => _isLoading = true);
    final data = await MemberService.getMembership();
    setState(() {
      _membership = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('My Membership'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _membership == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Data load nahi hua',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadMembership,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary),
                        child: const Text('Retry',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ✅ Top Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.card_membership,
                                color: Colors.white, size: 44),
                            const SizedBox(height: 10),
                            Text(
                              _membership!['plan'] ?? 'No Plan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: _membership!['status'] == 'active'
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (_membership!['status'] ?? 'inactive')
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ✅ Detail Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [AppTheme.cardShadow],
                        ),
                        child: Column(
                          children: [
                            _buildTile(Icons.calendar_today, 'Start Date',
                                _membership!['start_date']?.toString() ?? 'N/A'),
                            const Divider(height: 1),
                            _buildTile(Icons.calendar_month, 'End Date',
                                _membership!['end_date']?.toString() ?? 'N/A'),
                            const Divider(height: 1),
                            _buildTile(Icons.timer, 'Duration',
                                _membership!['duration']?.toString() ?? 'N/A'),
                            const Divider(height: 1),
                            _buildTile(Icons.attach_money, 'Plan Price',
                                'Rs. ${_membership!['price'] ?? '0'}'),
                            const Divider(height: 1),
                            _buildTile(Icons.payment, 'Amount Paid',
                                'Rs. ${_membership!['paid_amount'] ?? '0'}',
                                isLast: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTile(IconData icon, String label, String value,
      {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
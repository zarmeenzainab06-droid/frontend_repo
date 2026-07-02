import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/member_layout.dart';
import '../../core/services/member_service.dart';

class MemberMembershipScreen extends StatefulWidget {
  const MemberMembershipScreen({super.key});

  @override
  State<MemberMembershipScreen> createState() => _MemberMembershipScreenState();
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

  // Format date from ISO to readable format
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr == 'N/A') return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
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
      return '${months[date.month]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
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
          : _membership == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Data load nahi hua'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadMembership,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top Card - Plan name and status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.card_membership,
                          color: Colors.white,
                          size: 44,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _membership!['package_name'] ?? 'No Plan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Detail Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppTheme.cardShadow],
                    ),
                    child: Column(
                      children: [
                        // Start Date - formatted
                        _buildTile(
                          Icons.calendar_today,
                          'Start Date',
                          _formatDate(_membership!['start_date']?.toString()),
                        ),
                        const Divider(height: 1),
                        // End Date - formatted
                        _buildTile(
                          Icons.calendar_month,
                          'End Date',
                          _formatDate(_membership!['end_date']?.toString()),
                        ),
                        const Divider(height: 1),
                        // Duration
                        _buildTile(
                          Icons.timer,
                          'Duration',
                          '${_membership!['duration'] ?? 'N/A'} days',
                        ),
                        const Divider(height: 1),
                        // Price in PKR
                        _buildTile(
                          Icons.attach_money,
                          'Price',
                          'PKR ${_membership!['price'] ?? '0'}',
                        ),
                        const Divider(height: 1),
                        // Description
                        _buildTile(
                          Icons.description,
                          'Description',
                          _membership!['description']?.toString() ?? 'N/A',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
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
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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

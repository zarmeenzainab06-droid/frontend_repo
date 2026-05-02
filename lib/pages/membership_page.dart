import 'package:flutter/material.dart';
import 'membership_plans.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────

class MembershipInfo {
  final String userName;
  final String plan;
  final String expiryDate;
  final String trainerName;
  final int daysRemaining;
  final double nextPayment;
  final String paymentDueDate;
  final int workoutSessionsDone;
  final int workoutSessionsTotal;
  final List<RecentActivity> recentActivities;

  const MembershipInfo({
    required this.userName,
    required this.plan,
    required this.expiryDate,
    required this.trainerName,
    required this.daysRemaining,
    required this.nextPayment,
    required this.paymentDueDate,
    required this.workoutSessionsDone,
    required this.workoutSessionsTotal,
    required this.recentActivities,
  });
}

class RecentActivity {
  final String title;
  final String date;
  final int durationMins;

  const RecentActivity({
    required this.title,
    required this.date,
    required this.durationMins,
  });
}

// ─────────────────────────────────────────────
//  DUMMY DATA  (replace with real API later)
// ─────────────────────────────────────────────

final _demoMembership = MembershipInfo(
  userName: 'John',
  plan: 'Premium (6 Months)',
  expiryDate: 'July 15, 2026',
  trainerName: 'Mike Johnson',
  daysRemaining: 88,
  nextPayment: 299.00,
  paymentDueDate: 'July 16, 2026',
  workoutSessionsDone: 24,
  workoutSessionsTotal: 30,
  recentActivities: [
    RecentActivity(title: 'Strength Training', date: 'Today', durationMins: 45),
    RecentActivity(title: 'Cardio Session', date: 'Yesterday', durationMins: 30),
    RecentActivity(title: 'Yoga Class', date: 'Apr 16', durationMins: 60),
    RecentActivity(title: 'Strength Training', date: 'Apr 15', durationMins: 50),
  ],
);

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────

const _darkRed = Color(0xFF6B0F0F);
const _deepRed = Color(0xFF8B1A1A);
const _accentRed = Color(0xFFB22222);
const _green = Color(0xFF2E7D32);
const _lightGreen = Color(0xFF4CAF50);
const _bgWhite = Color(0xFFF5F5F5);
const _cardWhite = Colors.white;
const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF666666);

// ─────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  int _selectedIndex = 1; // Membership tab active by default
  bool _isPaymentLoading = false;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MembershipPlansPage()),
      );
    }
  }

  Future<void> _handlePayNow() async {
    setState(() => _isPaymentLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isPaymentLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment processed successfully! ✅'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleViewAllSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening all workout sessions...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = _demoMembership;
    return Scaffold(
      backgroundColor: _bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ──
            _buildHeader(m.userName),
            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMembershipStatusCard(m),
                    const SizedBox(height: 16),
                    _buildPaymentAndSessionRow(m),
                    const SizedBox(height: 16),
                    _buildRecentActivity(m.recentActivities),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ─────────────────────────────────

  Widget _buildHeader(String name) {
    return Container(
      width: double.infinity,
      color: _darkRed,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Here's your fitness journey overview",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Membership Status Card ──────────────────

  Widget _buildMembershipStatusCard(MembershipInfo m) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkRed, _deepRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _darkRed.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Active Badge
          Row(
            children: [
              const Text(
                'Membership Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Plan
          _membershipInfoRow(Icons.card_membership, 'Plan: ${m.plan}'),
          const SizedBox(height: 8),
          // Expiry
          _membershipInfoRow(Icons.calendar_today, 'Expiry Date: ${m.expiryDate}'),
          const SizedBox(height: 8),
          // Trainer
          _membershipInfoRow(Icons.person, 'Trainer: ${m.trainerName}'),
          const SizedBox(height: 16),
          // Days Remaining
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Days Remaining',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                Text(
                  '${m.daysRemaining}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _membershipInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  // ── Payment + Sessions Row ──────────────────

  Widget _buildPaymentAndSessionRow(MembershipInfo m) {
    return Row(
      children: [
        // Payment Card
        Expanded(child: _buildPaymentCard(m)),
        const SizedBox(width: 12),
        // Sessions Card
        Expanded(child: _buildSessionsCard(m)),
      ],
    );
  }

  Widget _buildPaymentCard(MembershipInfo m) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Next Payment',
                style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: _accentRed, shape: BoxShape.circle),
                child: const Icon(Icons.attach_money, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${m.nextPayment.toStringAsFixed(2)}',
            style: const TextStyle(color: _textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            'Due on ${m.paymentDueDate}',
            style: const TextStyle(color: _textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 14),
          // Pay Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPaymentLoading ? null : _handlePayNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isPaymentLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsCard(MembershipInfo m) {
    final progress = m.workoutSessionsDone / m.workoutSessionsTotal;
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workout Sessions',
                style: TextStyle(color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: _handleViewAllSessions,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                  child: const Icon(Icons.trending_up, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${m.workoutSessionsDone} / ${m.workoutSessionsTotal}',
            style: const TextStyle(color: _textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text('This month', style: TextStyle(color: _textSecondary, fontSize: 11)),
          const SizedBox(height: 14),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progress', style: TextStyle(color: _textSecondary, fontSize: 11)),
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(color: _textSecondary, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(_lightGreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent Activity ─────────────────────────

  Widget _buildRecentActivity(List<RecentActivity> activities) {
    return Container(
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...activities.map((a) => _buildActivityItem(a)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Circle check icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accentRed.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: _accentRed, size: 22),
          ),
          const SizedBox(width: 12),
          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title,
                    style: const TextStyle(
                        color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(a.date, style: const TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
          // Duration
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${a.durationMins} mins',
              style: const TextStyle(color: _accentRed, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ──────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.card_membership_outlined), activeIcon: Icon(Icons.card_membership), label: 'Membership'),
      BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Trainer'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
    ];

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
      selectedItemColor: _accentRed,
      unselectedItemColor: _textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      items: items,
    );
  }

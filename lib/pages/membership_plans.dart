import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────

const _darkRed = Color(0xFF6B0F0F);
const _accentRed = Color(0xFFB22222);
const _darkNavy = Color(0xFF1A2340);
const _green = Color(0xFF2E7D32);
const _bgWhite = Color(0xFFF5F5F5);
const _textPrimary = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF666666);

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────

class CurrentPlan {
  final String name;
  final String expiresOn;
  final int daysLeft;
  const CurrentPlan({required this.name, required this.expiresOn, required this.daysLeft});
}

class MembershipPlan {
  final String title;
  final String duration;
  final double price;
  final List<String> features;
  final bool isCurrent;
  final bool isMostPopular;

  const MembershipPlan({
    required this.title,
    required this.duration,
    required this.price,
    required this.features,
    this.isCurrent = false,
    this.isMostPopular = false,
  });
}

// ─────────────────────────────────────────────
//  DUMMY DATA
// ─────────────────────────────────────────────

const _currentPlan = CurrentPlan(
  name: 'Premium (6 Months)',
  expiresOn: 'July 15, 2026',
  daysLeft: 88,
);

const _plans = [
  MembershipPlan(
    title: 'Basic',
    duration: '1 Month',
    price: 49,
    features: [
      'Access to gym equipment',
      'Locker facility',
      'Basic support',
    ],
  ),
  MembershipPlan(
    title: 'Standard',
    duration: '3 Months',
    price: 129,
    features: [
      'All Basic features',
      'Group classes',
      'Nutrition guidance',
      'Progress tracking',
    ],
  ),
  MembershipPlan(
    title: 'Premium',
    duration: '6 Months',
    price: 299,
    features: [
      'All Standard features',
      'Personal trainer',
      'Diet plan',
      'Priority support',
      'Free merchandise',
    ],
    isCurrent: true,
    isMostPopular: true,
  ),
  MembershipPlan(
    title: 'Yearly',
    duration: '12 Months',
    price: 499,
    features: [
      'All Premium features',
      'Dedicated trainer',
      'Supplement guidance',
      'Free guest passes',
      'Spa access',
    ],
  ),
];

// ─────────────────────────────────────────────
//  PAGE
// ─────────────────────────────────────────────

class MembershipPlansPage extends StatefulWidget {
  const MembershipPlansPage({super.key});

  @override
  State<MembershipPlansPage> createState() => _MembershipPlansPageState();
}

class _MembershipPlansPageState extends State<MembershipPlansPage> {
  int _selectedNav = 1;
  String? _loadingPlan; // which plan button is loading

  void _handleChoosePlan(MembershipPlan plan) async {
    setState(() => _loadingPlan = plan.title);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loadingPlan = null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plan.title} plan selected! ✅'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleRenewPlan() async {
    setState(() => _loadingPlan = 'renew');
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loadingPlan = null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Plan renewed successfully! 🎉'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page Title
                    const Text(
                      'Membership Plans',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose the plan that fits your fitness goals',
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // ── Current Plan Card
                    _buildCurrentPlanCard(_currentPlan),
                    const SizedBox(height: 24),

                    // ── Available Plans title
                    const Text(
                      'Available Plans',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Plans Grid (2 columns)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _plans.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (ctx, i) => _buildPlanCard(_plans[i]),
                    ),

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

  // ── App Bar ─────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: _darkRed,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'GymSwift ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'Member Portal',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Current Plan Card ───────────────────────

  Widget _buildCurrentPlanCard(CurrentPlan plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accentRed.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Plan',
                style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3 info boxes
          Row(
            children: [
              Expanded(child: _planInfoBox(Icons.attach_money, 'Plan', plan.name)),
              const SizedBox(width: 10),
              Expanded(child: _planInfoBox(Icons.calendar_today, 'Expires On', plan.expiresOn)),
              const SizedBox(width: 10),
              Expanded(child: _planInfoBox(Icons.access_time, 'Days Left', '${plan.daysLeft} Days')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planInfoBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: _accentRed.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(color: _darkRed, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: _textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ── Individual Plan Card ────────────────────

  Widget _buildPlanCard(MembershipPlan plan) {
    final isCurrent = plan.isCurrent;
    final isLoading = _loadingPlan == plan.title;
    final isRenewLoading = _loadingPlan == 'renew';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isCurrent
                ? Border.all(color: _accentRed, width: 2)
                : Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                plan.title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                plan.duration,
                style: const TextStyle(color: _textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),

              // Price
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$${plan.price.toInt()}',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' /total',
                      style: TextStyle(color: _textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Features
              ...plan.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: isCurrent ? _accentRed : _green,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(color: _textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Button
              isCurrent
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (isRenewLoading) ? null : _handleRenewPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: isRenewLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Renew Plan',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _handleChoosePlan(plan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Choose Plan',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
            ],
          ),
        ),

        // ── Most Popular Badge ──
        if (plan.isMostPopular)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Bottom Nav ──────────────────────────────

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedNav,
      onTap: (i) {
        setState(() => _selectedNav = i);
        Navigator.pushNamed(context, '/plans');
      },
      selectedItemColor: _accentRed,
      unselectedItemColor: _textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.card_membership_outlined), activeIcon: Icon(Icons.card_membership), label: 'Membership'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Trainer'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ,
    );
  }
}
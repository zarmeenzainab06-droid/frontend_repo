import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerMemberProfileScreen extends StatefulWidget {
  @override
  State<TrainerMemberProfileScreen> createState() =>
      _TrainerMemberProfileScreenState();
}

class _TrainerMemberProfileScreenState
    extends State<TrainerMemberProfileScreen> {
  late Map<String, dynamic> member;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;

    // ── Accept arguments from BOTH sources ────────────────────
    // 1. From Members screen: full member map
    // 2. From Diet Plans screen: { 'id': x, 'name': y } — fetch full data
    if (args is Map<String, dynamic>) {
      member = args;
      // If only id + name passed (from diet plans), fetch full profile
      if (!member.containsKey('email') && member.containsKey('id')) {
        _fetchMember(member['id']);
      }
    } else {
      member = {};
    }
  }

  Future<void> _fetchMember(int id) async {
    setState(() => _isLoading = true);
    final result = await TrainerService.getMemberById(id);
    if (result['success']) {
      setState(() => member = result['member']);
    }
    setState(() => _isLoading = false);
  }

  // ── Helpers ───────────────────────────────────────────────────
  String get _name => member['name'] ?? 'Member';
  String get _initial => _name.isNotEmpty ? _name[0].toUpperCase() : 'M';
  String get _email => member['email'] ?? 'N/A';

  String get _phone =>
      (member['phone'] != null && member['phone'].toString().isNotEmpty)
      ? member['phone'].toString()
      : 'N/A';

  String get _gender => member['gender'] != null
      ? member['gender'].toString()[0].toUpperCase() +
            member['gender'].toString().substring(1)
      : 'N/A';

  String get _slot => member['training_slot'] ?? '';

  String get _slotLabel {
    switch (_slot.toLowerCase()) {
      case 'morning':
        return 'Morning (6:00 AM)';
      case 'midday':
        return 'Midday (12:00 PM)';
      case 'evening':
        return 'Evening (6:00 PM)';
      case 'night':
        return 'Night (8:00 PM)';
      default:
        return _slot.isNotEmpty ? _slot : 'N/A';
    }
  }

  String get _plan =>
      (member['plan'] != null && member['plan'].toString().isNotEmpty)
      ? member['plan'].toString()
      : 'No Package';

  String get _membershipStatus =>
      (member['membership_status'] ?? 'pending').toString().toLowerCase();

  String get _endDate => member['end_date'] != null
      ? _formatDate(member['end_date'].toString())
      : 'N/A';

  String get _joinedDate => member['created_at'] != null
      ? _formatDate(member['created_at'].toString())
      : 'N/A';

  String get _workoutType =>
      member['workout_type'] ?? member['diet_plan_title'] ?? '';

  String get _dietPlanTitle => member['diet_plan_title'] ?? '';

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
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
      return '${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Color get _statusColor {
    switch (_membershipStatus) {
      case 'active':
        return AppTheme.active;
      case 'expired':
      case 'frozen':
        return AppTheme.textSecondary;
      default:
        return AppTheme.pending;
    }
  }

  String get _statusLabel {
    switch (_membershipStatus) {
      case 'active':
        return 'active';
      case 'expired':
      case 'frozen':
        return 'inactive';
      default:
        return 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const TrainerDrawer(),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Member Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileCard(),
                        const SizedBox(height: 14),
                        _buildMembershipCard(),
                        const SizedBox(height: 14),
                        _buildJoinedCard(),
                        const SizedBox(height: 14),
                        _buildContactCard(),
                        const SizedBox(height: 14),
                        _buildTrainingCard(),
                        // ── Diet Plan Info (if assigned) ───────
                        if (_dietPlanTitle.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildDietCard(),
                        ],
                        const SizedBox(height: 14),

                        // ── Contact Button ─────────────────────
                        _buildContactButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 4,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'GymFitex',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Trainer Portal',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Red Profile Card ──────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _gender,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _membershipStatus == 'active'
                        ? Colors.greenAccent
                        : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _statusLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Membership Card ───────────────────────────────────────────
  Widget _buildMembershipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membership',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _infoTile(
            icon: Icons.card_membership_outlined,
            label: 'Package',
            value: _plan,
          ),
          const SizedBox(height: 10),
          _infoTile(
            icon: Icons.circle,
            label: 'Status',
            value: _statusLabel,
            valueColor: _statusColor,
          ),
          const SizedBox(height: 10),
          _infoTile(
            icon: Icons.event_outlined,
            label: 'Expires',
            value: _endDate,
          ),
        ],
      ),
    );
  }

  // ── Joined Date Card ──────────────────────────────────────────
  Widget _buildJoinedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _joinedDate,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Joined Date',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Contact Card ──────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _contactRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: _email,
          ),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: _phone,
          ),
        ],
      ),
    );
  }

  // ── Training Card ─────────────────────────────────────────────
  Widget _buildTrainingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _contactRow(
            icon: Icons.access_time_outlined,
            label: 'Training Slot',
            value: _slotLabel,
          ),
          const SizedBox(height: 12),
          _contactRow(icon: Icons.wc_outlined, label: 'Gender', value: _gender),
          if (_workoutType.isNotEmpty) ...[
            const SizedBox(height: 12),
            _contactRow(
              icon: Icons.fitness_center_outlined,
              label: 'Workout Type',
              value: _workoutType,
            ),
          ],
        ],
      ),
    );
  }

  // ── Diet Plan Card (shown if diet assigned) ───────────────────
  Widget _buildDietCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diet Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _contactRow(
            icon: Icons.restaurant_menu_outlined,
            label: 'Assigned Plan',
            value: _dietPlanTitle,
          ),
        ],
      ),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────
  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Contact Button ────────────────────────────────────────────
  Widget _buildContactButton() {
    return GestureDetector(
      onTap: () {
        final phone = _phone != 'N/A' ? _phone : '';
        if (phone.isNotEmpty) {
          Get.snackbar(
            'Contact $_name',
            'Phone: $phone',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.phone_rounded, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'No Phone',
            'No contact number available for $_name',
            backgroundColor: AppTheme.expired,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              _phone != 'N/A' ? 'Call $_phone' : 'Contact Member',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav (5 items) ──────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                Icons.home_outlined,
                'Home',
                onTap: () => Get.offNamed('/trainer-dashboard'),
              ),
              _navItem(
                Icons.people_outline_rounded,
                'Members',
                isActive: true,
                onTap: () => Get.offNamed('/trainer/members'),
              ),
              _navItem(
                Icons.restaurant_menu_outlined,
                'Diet Plans',
                onTap: () => Get.toNamed('/trainer/diet-plans'),
              ),
              _navItem(
                Icons.calendar_month_outlined,
                'Schedule',
                onTap: () => Get.toNamed('/trainer/schedule'),
              ),
              _navItem(
                Icons.person_outline_rounded,
                'Profile',
                onTap: () => Get.toNamed('/trainer/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

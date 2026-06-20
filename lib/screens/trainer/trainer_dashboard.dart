import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerDashboard extends StatefulWidget {
  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  final box = GetStorage();
  bool _isLoading = true;

  // ── Stats ──────────────────────────────────────────────────
  int assignedMembers = 0;
  int todaySlots = 0;
  int activeMemberships = 0;
  int totalDietPlans = 0;
  int activeDietPlans = 0;
  int pendingDietPlans = 0;
  int completedToday = 0;

  List<Map<String, dynamic>> _sessions = [];

  String get _trainerName {
    final user = box.read('user');
    if (user == null) return 'Trainer';
    return user['name'] ?? 'Trainer';
  }

  String get _trainerInitial =>
      _trainerName.isNotEmpty ? _trainerName[0].toUpperCase() : 'T';

  String get _trainerSpecialty {
    final user = box.read('user');
    if (user == null) return '';
    return user['specialty'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    final statsResult = await TrainerService.getDashboardStats();
    final scheduleResult = await TrainerService.getTodaySchedule();
    final dietResult = await TrainerService.getDietPlans();

    if (statsResult['success']) {
      final s = statsResult['stats'];
      setState(() {
        assignedMembers = s['totalMembers'] ?? 0;
        todaySlots = s['todaySlots'] ?? 0;
        activeMemberships = s['activeMemberships'] ?? 0;
      });
    }

    if (scheduleResult['success']) {
      final list = List<Map<String, dynamic>>.from(scheduleResult['schedule']);
      // Descending: night → evening → midday → morning
      const slotOrder = ['night', 'evening', 'midday', 'morning'];
      list.sort((a, b) {
        final ai = slotOrder.indexOf(
          (a['training_slot'] ?? '').toString().toLowerCase(),
        );
        final bi = slotOrder.indexOf(
          (b['training_slot'] ?? '').toString().toLowerCase(),
        );
        return ai.compareTo(bi);
      });
      setState(() => _sessions = list);
    }

    if (dietResult['success']) {
      final s = dietResult['stats'];
      setState(() {
        totalDietPlans = s['totalPlans'] ?? 0;
        activeDietPlans = s['activePlans'] ?? 0;
        pendingDietPlans = s['noPlan'] ?? 0;
        completedToday = activeMemberships > 0
            ? (activeMemberships * 0.25).round()
            : 0;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const TrainerDrawer(),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _loadDashboard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Welcome Banner ──────────────────
                          _buildWelcomeBanner(),
                          const SizedBox(height: 20),

                          // ── Horizontal Stat Cards ────────────
                          _buildHorizontalStats(),
                          const SizedBox(height: 20),

                          // ── Quick Action Buttons ─────────────
                          _buildQuickActions(),
                          const SizedBox(height: 24),

                          // ── Upcoming Sessions ────────────────
                          const Text(
                            'Upcoming Sessions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLg,
                              ),
                              boxShadow: [AppTheme.cardShadow],
                            ),
                            child: _sessions.isEmpty
                                ? _buildEmptyState(
                                    icon: Icons.calendar_today_outlined,
                                    text: 'No sessions scheduled today',
                                  )
                                : Column(
                                    children: _sessions
                                        .map(
                                          (s) => _buildSessionRow(
                                            s,
                                            isLast: s == _sessions.last,
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // ── Diet Plans Overview ───────────────
                          _buildDietPlansOverview(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 8,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
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

  // ── Welcome Banner ────────────────────────────────────────────
  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _trainerInitial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,\n$_trainerName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                if (_trainerSpecialty.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _trainerSpecialty,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Horizontal Scrollable Stat Cards ─────────────────────────
  Widget _buildHorizontalStats() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _horizStatCard(
            icon: Icons.people_alt_rounded,
            iconBg: Colors.blue,
            value: '$assignedMembers',
            label: 'Assigned Members',
            sub: '+3 this month',
            subColor: Colors.blue,
          ),
          const SizedBox(width: 12),
          _horizStatCard(
            icon: Icons.restaurant_menu_outlined,
            iconBg: Colors.green,
            value: '$activeDietPlans',
            label: 'Active Diet Plans',
            sub: '$pendingDietPlans need update',
            subColor: Colors.orange,
          ),
          const SizedBox(width: 12),
          _horizStatCard(
            icon: Icons.access_time_rounded,
            iconBg: AppTheme.primary,
            value: '$todaySlots',
            label: "Today's Sessions",
            sub: '${todaySlots - completedToday} remaining',
            subColor: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          _horizStatCard(
            icon: Icons.check_circle_outline_rounded,
            iconBg: Colors.orange,
            value: '$completedToday',
            label: 'Completed',
            sub:
                '${todaySlots > 0 ? ((completedToday / todaySlots) * 100).toStringAsFixed(0) : 0}% done',
            subColor: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _horizStatCard({
    required IconData icon,
    required Color iconBg,
    required String value,
    required String label,
    required String sub,
    required Color subColor,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: subColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Quick Action Buttons (4 colored) ─────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickBtn(
            icon: Icons.people_outline_rounded,
            label: 'View Members',
            color: AppTheme.primary,
            onTap: () => Get.toNamed('/trainer/members'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickBtn(
            icon: Icons.restaurant_menu_outlined,
            label: 'Diet Plans',
            color: Colors.green,
            onTap: () => Get.toNamed('/trainer/diet-plans'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickBtn(
            icon: Icons.calendar_month_outlined,
            label: 'Schedule',
            color: Colors.blue,
            onTap: () => Get.toNamed('/trainer/schedule'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickBtn(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            color: Colors.purple,
            onTap: () => Get.toNamed('/trainer/profile'),
          ),
        ),
      ],
    );
  }

  Widget _quickBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Session Row ───────────────────────────────────────────────
  Widget _buildSessionRow(Map<String, dynamic> session, {bool isLast = false}) {
    final name = session['memberName'] ?? session['member_name'] ?? '';
    final slot = (session['training_slot'] ?? '').toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final time = _slotToTime(slot);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      slot.isNotEmpty
                          ? '${slot[0].toUpperCase()}${slot.substring(1)} Training'
                          : 'Training Session',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'upcoming',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppTheme.border,
          ),
      ],
    );
  }

  // ── Diet Plans Overview ───────────────────────────────────────
  Widget _buildDietPlansOverview() {
    return Column(
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.restaurant_menu_outlined,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Diet Plans Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed('/trainer/diet-plans'),
              child: Row(
                children: const [
                  Text(
                    'Manage',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.green, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3 stat cards
        Row(
          children: [
            Expanded(
              child: _dietStatCard(
                '$totalDietPlans',
                'Total Plans',
                const Color(0xFFE8F5E9),
                Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dietStatCard(
                '$activeDietPlans',
                'Active',
                const Color(0xFFE3F2FD),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dietStatCard(
                '$pendingDietPlans',
                'Pending',
                const Color(0xFFFFF3E0),
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Manage All button
        GestureDetector(
          onTap: () => Get.toNamed('/trainer/diet-plans'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.green, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.restaurant_menu_outlined,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Manage All Diet Plans',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dietStatCard(String value, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  String _slotToTime(String slot) {
    switch (slot.toLowerCase()) {
      case 'morning':
        return '6:00 AM';
      case 'midday':
        return '12:00 PM';
      case 'evening':
        return '5:00 PM';
      case 'night':
        return '8:00 PM';
      default:
        return slot;
    }
  }

  Widget _buildEmptyState({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 44, color: AppTheme.textHint),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
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
              _navItem(Icons.home_rounded, 'Home', isActive: true),
              _navItem(
                Icons.people_outline_rounded,
                'Members',
                onTap: () => Get.toNamed('/trainer/members'),
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

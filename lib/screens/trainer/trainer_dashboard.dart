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

  // ── Data ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _activity = [];

  // ── Trainer info ───────────────────────────────────────────
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
    final activityResult = await TrainerService.getRecentActivity();

    if (statsResult['success']) {
      final s = statsResult['stats'];
      setState(() {
        assignedMembers = s['totalMembers'] ?? 0;
        todaySlots = s['todaySlots'] ?? 0;
        activeMemberships = s['activeMemberships'] ?? 0;
      });
    }

    if (scheduleResult['success']) {
      setState(() {
        _sessions = List<Map<String, dynamic>>.from(scheduleResult['schedule']);
      });
    }

    if (activityResult['success']) {
      setState(() {
        _activity = List<Map<String, dynamic>>.from(activityResult['activity']);
      });
    }

    setState(() => _isLoading = false);
  }

  void _logout() {
    box.remove('token');
    box.remove('user');
    box.remove('role');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: _buildDrawer(),
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
                          const SizedBox(height: 16),

                          // ── Stat Cards ──────────────────────
                          _buildStatCard(
                            label: 'Assigned Members',
                            value: assignedMembers,
                            subtitle: '+3 this month',
                            subtitleColor: AppTheme.active,
                            subtitleIcon: Icons.trending_up,
                            icon: Icons.people_alt_rounded,
                            iconColor: Colors.blue,
                            iconBg: Colors.blue.withOpacity(0.12),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            label: "Today's Slots",
                            value: todaySlots,
                            subtitle: '$todaySlots sessions scheduled',
                            subtitleColor: AppTheme.textSecondary,
                            icon: Icons.access_time_rounded,
                            iconColor: AppTheme.primary,
                            iconBg: AppTheme.primaryLight,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            label: 'Completed Today',
                            value: activeMemberships,
                            subtitle: todaySlots > 0
                                ? '${((activeMemberships / (todaySlots > 0 ? todaySlots : 1)) * 100).toStringAsFixed(0)}% progress'
                                : '0% progress',
                            subtitleColor: AppTheme.textSecondary,
                            icon: Icons.check_circle_rounded,
                            iconColor: AppTheme.active,
                            iconBg: AppTheme.activeLight,
                          ),
                          const SizedBox(height: 20),

                          // ── Quick Actions ────────────────────
                          _buildQuickActionsGrid(),
                          const SizedBox(height: 20),

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
                          const SizedBox(height: 20),

                          // ── Recent Member Activity ────────────
                          const Text(
                            'Recent Member Activity',
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
                            child: _activity.isEmpty
                                ? _buildEmptyState(
                                    icon: Icons.history_outlined,
                                    text: 'No recent activity',
                                  )
                                : Column(
                                    children: _activity
                                        .map(
                                          (item) => _buildActivityRow(
                                            item,
                                            isLast: item == _activity.last,
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
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

  // ── Stat Card ─────────────────────────────────────────────────
  Widget _buildStatCard({
    required String label,
    required int value,
    required String subtitle,
    required Color subtitleColor,
    IconData? subtitleIcon,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (subtitleIcon != null) ...[
                      Icon(subtitleIcon, size: 13, color: subtitleColor),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions 2×2 ─────────────────────────────────────────
  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.calendar_month_rounded,
                label: 'View Schedule',
                isActive: true,
                onTap: () => Get.toNamed('/trainer/schedule'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.people_outline_rounded,
                label: 'My Members',
                isActive: false,
                onTap: () => Get.toNamed('/trainer/members'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.add,
                label: 'Add Session',
                isActive: false,
                onTap: () => Get.toNamed('/trainer/add-session'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.show_chart_rounded,
                label: 'Progress',
                isActive: false,
                onTap: () => Get.toNamed('/trainer/progress'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.textPrimary,
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
              // Red avatar
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
              // Time + upcoming badge
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

  // ── Activity Row ──────────────────────────────────────────────
  Widget _buildActivityRow(Map<String, dynamic> item, {bool isLast = false}) {
    final name = item['memberName'] ?? item['name'] ?? '';
    final action = item['action'] ?? '';
    final timeAgo = item['timeAgo'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Blue avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.blue,
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
                      action,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
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

  // ── Helpers ───────────────────────────────────────────────────
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

  // ── Drawer ────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 20,
              right: 20,
              bottom: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _trainerInitial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _trainerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Trainer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _drawerItem(
            Icons.home_outlined,
            'Dashboard',
            () => Get.back(),
            isActive: true,
          ),
          _drawerItem(Icons.people_outline, 'My Members', () {
            Get.back();
            Get.toNamed('/trainer/members');
          }),
          _drawerItem(Icons.calendar_month_outlined, 'Schedule', () {
            Get.back();
            Get.toNamed('/trainer/schedule');
          }),
          _drawerItem(Icons.show_chart_rounded, 'Progress', () {
            Get.back();
            Get.toNamed('/trainer/progress');
          }),
          _drawerItem(Icons.person_outline, 'Profile', () {
            Get.back();
            Get.toNamed('/trainer/profile');
          }),
          const Spacer(),
          const Divider(height: 1, color: AppTheme.border),
          _drawerItem(Icons.logout, 'Logout', _logout, color: AppTheme.expired),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isActive = false,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: color ?? (isActive ? AppTheme.primary : AppTheme.textSecondary),
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? (isActive ? AppTheme.primary : AppTheme.textPrimary),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
        ),
      ),
      tileColor: isActive ? AppTheme.primaryLight : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────
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
              fontSize: 11,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

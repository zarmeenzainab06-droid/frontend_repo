import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';
import '../../core/widgets/notification_bell.dart'; // ← NEW: in-app notifications

class TrainerDashboard extends StatefulWidget {
  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  final box = GetStorage();
  bool _isLoading = true;

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
    return user['specialty'] ?? user['specialization'] ?? '';
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
      // Sort by start_time ascending (earliest first)
      list.sort((a, b) {
        final at = _parseTime(a['start_time']?.toString() ?? '');
        final bt = _parseTime(b['start_time']?.toString() ?? '');
        return at.compareTo(bt);
      });

      // Count completed sessions (end_time has passed)
      final now = TimeOfDay.now();
      int completed = 0;
      for (final s in list) {
        if (_isSessionCompleted(s['end_time']?.toString() ?? '', now)) {
          completed++;
        }
      }

      setState(() {
        _sessions = list;
        completedToday = completed;
        todaySlots = list.length;
      });
    }

    if (dietResult['success']) {
      final s = dietResult['stats'];
      setState(() {
        totalDietPlans = s['totalPlans'] ?? 0;
        activeDietPlans = s['activePlans'] ?? 0;
        pendingDietPlans = s['noPlan'] ?? 0;
      });
    }

    setState(() => _isLoading = false);
  }

  // ── Time helpers ──────────────────────────────────────────────
  // Parse "06:00 AM" or "06:00:00" → minutes since midnight
  int _parseTime(String t) {
    if (t.isEmpty) return 9999;
    try {
      t = t.trim();
      // Handle "HH:MM AM/PM"
      if (t.contains('AM') || t.contains('PM')) {
        final parts = t.split(' ');
        final isPM = parts[1].toUpperCase() == 'PM';
        final hm = parts[0].split(':');
        int h = int.parse(hm[0]);
        final m = int.parse(hm[1]);
        if (isPM && h != 12) h += 12;
        if (!isPM && h == 12) h = 0;
        return h * 60 + m;
      }
      // Handle "HH:MM:SS"
      final hm = t.split(':');
      return int.parse(hm[0]) * 60 + int.parse(hm[1]);
    } catch (_) {
      return 9999;
    }
  }

  bool _isSessionCompleted(String endTime, TimeOfDay now) {
    final endMins = _parseTime(endTime);
    final nowMins = now.hour * 60 + now.minute;
    return endMins != 9999 && nowMins > endMins;
  }

  // Format "06:00:00" or "06:00 AM" → "6:00 AM"
  String _formatTime(String? t) {
    if (t == null || t.isEmpty) return '';
    try {
      t = t.trim();
      if (t.contains('AM') || t.contains('PM')) return t;
      final parts = t.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final suffix = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $suffix';
    } catch (_) {
      return t ?? '';
    }
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
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 197, 179, 179),
                    ),
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
                          _buildWelcomeBanner(),
                          const SizedBox(height: 20),

                          // ── Horizontal Stat Cards ────────────
                          _buildHorizontalStats(),
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
          const Spacer(),
          const NotificationBell(),
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

  // ── Horizontal Stat Cards ─────────────────────────────────────
  Widget _buildHorizontalStats() {
    final remaining = todaySlots - completedToday;
    return SizedBox(
      height: 150,
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
            sub: '$remaining remaining',
            subColor: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          _horizStatCard(
            icon: Icons.check_circle_outline_rounded,
            iconBg: Colors.orange,
            value: '$completedToday',
            label: 'Completed',
            sub: todaySlots > 0
                ? '${((completedToday / todaySlots) * 100).toStringAsFixed(0)}% done'
                : '0% done',
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

  // ── Session Row — real time-based status ──────────────────────
  Widget _buildSessionRow(Map<String, dynamic> session, {bool isLast = false}) {
    final name = session['memberName'] ?? '';
    final slotName = session['slot_name'] ?? session['training_slot'] ?? '';
    final startTime = _formatTime(session['start_time']?.toString());
    final endTime = session['end_time']?.toString() ?? '';
    final workout = session['workout_type'] ?? 'General Fitness';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final runsToday = session['runs_today'] ?? true;

    final now = TimeOfDay.now();
    final completed = _isSessionCompleted(endTime, now);

    // Time range label
    final timeLabel = startTime.isNotEmpty
        ? '$startTime – ${_formatTime(endTime)}'
        : slotName;

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
                    const SizedBox(height: 2),
                    Text(
                      workout,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (!runsToday)
                      const Text(
                        'Not scheduled today',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 11,
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
                      color: !runsToday
                          ? AppTheme.textSecondary
                          : completed
                          ? AppTheme.active
                          : const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      !runsToday
                          ? 'off today'
                          : completed
                          ? 'completed'
                          : 'upcoming',
                      style: const TextStyle(
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

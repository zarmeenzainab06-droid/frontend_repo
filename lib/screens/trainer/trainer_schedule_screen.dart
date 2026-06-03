import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerScheduleScreen extends StatefulWidget {
  @override
  State<TrainerScheduleScreen> createState() => _TrainerScheduleScreenState();
}

class _TrainerScheduleScreenState extends State<TrainerScheduleScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedule = [];

  // ── Slot config — hardcoded time ranges ────────────────────
  static const Map<String, Map<String, dynamic>> _slotConfig = {
    'morning': {
      'label': 'Morning Sessions',
      'timeRange': '6:00 AM - 7:00 AM',
      'endHour': 7,
      'endMin': 0,
      'iconBg': Color(0xFFFF6B35), // orange
      'sectionBg': Color(0xFFFF6B35),
    },
    'midday': {
      'label': 'Midday Sessions',
      'timeRange': '12:00 PM - 1:00 PM',
      'endHour': 13,
      'endMin': 0,
      'iconBg': Color(0xFF2196F3), // blue
      'sectionBg': Color(0xFF2196F3),
    },
    'evening': {
      'label': 'Evening Sessions',
      'timeRange': '6:00 PM - 7:00 PM',
      'endHour': 19,
      'endMin': 0,
      'iconBg': Color(0xFF9C27B0), // purple
      'sectionBg': Color(0xFF9C27B0),
    },
    'night': {
      'label': 'Night Sessions',
      'timeRange': '8:00 PM - 9:00 PM',
      'endHour': 21,
      'endMin': 0,
      'iconBg': Color(0xFF607D8B), // blue grey
      'sectionBg': Color(0xFF607D8B),
    },
  };

  // ── Is this slot's time already passed? ───────────────────
  bool _isSlotCompleted(String slot) {
    final now = DateTime.now();
    final config = _slotConfig[slot];
    if (config == null) return false;
    final endHour = config['endHour'] as int;
    final endMin = config['endMin'] as int;
    final slotEnd = DateTime(now.year, now.month, now.day, endHour, endMin);
    return now.isAfter(slotEnd);
  }

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    final result = await TrainerService.getTodaySchedule();
    if (result['success']) {
      setState(() {
        _schedule = List<Map<String, dynamic>>.from(result['schedule']);
      });
    }
    setState(() => _isLoading = false);
  }

  // ── Group members by slot ──────────────────────────────────
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final Map<String, List<Map<String, dynamic>>> map = {
      'morning': [],
      'midday': [],
      'evening': [],
      'night': [],
    };
    for (final m in _schedule) {
      final slot = (m['training_slot'] ?? '').toString().toLowerCase();
      if (map.containsKey(slot)) {
        map[slot]!.add(m);
      }
    }
    return map;
  }

  // ── Today's date formatted ─────────────────────────────────
  String get _todayLabel {
    return DateFormat('EEEE, MMMM d, y').format(DateTime.now());
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
                    onRefresh: _loadSchedule,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title ────────────────────────
                          const Text(
                            'Schedule',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ── Date display ─────────────────
                          _buildDateDisplay(),
                          const SizedBox(height: 20),

                          // ── Slot sections ─────────────────
                          ..._buildSlotSections(),
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

  // ── Date Display ──────────────────────────────────────────────
  Widget _buildDateDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppTheme.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            _todayLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build all slot sections ───────────────────────────────────
  List<Widget> _buildSlotSections() {
    final grouped = _grouped;
    final List<Widget> sections = [];
    final slotOrder = ['morning', 'midday', 'evening', 'night'];

    for (final slot in slotOrder) {
      final members = grouped[slot] ?? [];
      if (members.isEmpty) continue;

      final config = _slotConfig[slot]!;
      final completed = _isSlotCompleted(slot);

      sections.add(
        _buildSlotSection(
          slot: slot,
          config: config,
          members: members,
          completed: completed,
        ),
      );
      sections.add(const SizedBox(height: 16));
    }

    if (sections.isEmpty) {
      sections.add(_buildEmptyState());
    }

    return sections;
  }

  // ── Single Slot Section ───────────────────────────────────────
  Widget _buildSlotSection({
    required String slot,
    required Map<String, dynamic> config,
    required List<Map<String, dynamic>> members,
    required bool completed,
  }) {
    final upcomingCount = completed ? 0 : members.length;
    final iconBg = config['iconBg'] as Color;
    final sectionColor = config['sectionBg'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──────────────────────────────────
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: sectionColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: sectionColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              config['label'] as String,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: sectionColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Slot Card ───────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [AppTheme.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time + members count + location
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    // Orange/colored clock icon box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config['timeRange'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 13,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${members.length} member${members.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Main Floor',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Upcoming badge
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: completed
                        ? AppTheme.active
                        : const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    completed ? 'All Completed' : '$upcomingCount Upcoming',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Divider(height: 1, color: AppTheme.border),

              // Member rows
              ...members.map(
                (m) => _buildMemberRow(
                  m,
                  completed: completed,
                  isLast: m == members.last,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Member Row inside slot card ───────────────────────────────
  Widget _buildMemberRow(
    Map<String, dynamic> member, {
    required bool completed,
    bool isLast = false,
  }) {
    final name = member['memberName'] ?? '';
    final workoutType = member['workout_type'] ?? 'General Fitness';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Red avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name + workout type
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
                      workoutType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge — time-based
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: completed ? AppTheme.active : const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  completed ? 'completed' : 'upcoming',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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

  // ── Empty state ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 56,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 14),
            const Text(
              'No sessions scheduled',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Members will appear here when assigned',
              style: TextStyle(fontSize: 13, color: AppTheme.textHint),
            ),
          ],
        ),
      ),
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
              _navItem(
                Icons.home_outlined,
                'Home',
                onTap: () => Get.offNamed('/trainer-dashboard'),
              ),
              _navItem(
                Icons.people_outline_rounded,
                'Members',
                onTap: () => Get.offNamed('/trainer/members'),
              ),
              _navItem(
                Icons.calendar_month_outlined,
                'Schedule',
                isActive: true,
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

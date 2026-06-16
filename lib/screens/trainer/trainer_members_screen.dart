import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';

class TrainerMembersScreen extends StatefulWidget {
  @override
  State<TrainerMembersScreen> createState() => _TrainerMembersScreenState();
}

class _TrainerMembersScreenState extends State<TrainerMembersScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _filtered = [];

  // Filter: 'all' | 'diet_assigned' | 'no_diet'
  String _dietFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final result = await TrainerService.getMyMembers(
      search: _searchController.text,
    );
    if (result['success']) {
      _members = List<Map<String, dynamic>>.from(result['members']);
      _applyFilter();
    }
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    List<Map<String, dynamic>> list = List.from(_members);
    if (_dietFilter == 'diet_assigned') {
      list = list.where((m) => m['diet_plan_id'] != null).toList();
    } else if (_dietFilter == 'no_diet') {
      list = list.where((m) => m['diet_plan_id'] == null).toList();
    }
    setState(() => _filtered = list);
  }

  void _applySearch(String query) {
    List<Map<String, dynamic>> list = List.from(_members);
    if (_dietFilter == 'diet_assigned')
      list = list.where((m) => m['diet_plan_id'] != null).toList();
    else if (_dietFilter == 'no_diet')
      list = list.where((m) => m['diet_plan_id'] == null).toList();
    if (query.isNotEmpty) {
      list = list.where((m) {
        final name = (m['name'] ?? '').toString().toLowerCase();
        final email = (m['email'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    }
    setState(() => _filtered = list);
  }

  String _slotLabel(String slot) {
    switch (slot.toLowerCase()) {
      case 'morning':
        return 'Morning (6:00 AM)';
      case 'midday':
        return 'Midday (12:00 PM)';
      case 'evening':
        return 'Evening (6:00 PM)';
      case 'night':
        return 'Night (8:00 PM)';
      default:
        return slot;
    }
  }

  // Attendance % based on membership status
  int _progressPercent(Map<String, dynamic> m) {
    switch ((m['membership_status'] ?? '').toString().toLowerCase()) {
      case 'active':
        return 90;
      case 'expired':
        return 60;
      default:
        return 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildTopBar(),
          _buildHeader(),
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : _filtered.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _loadMembers,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _buildMemberCard(_filtered[i]),
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

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Members',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${_members.length} members assigned to you',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_members.length} Total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _applySearch,
        decoration: InputDecoration(
          hintText: 'Search members by name...',
          hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textHint,
            size: 20,
          ),
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: const BorderSide(color: AppTheme.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Filter Tabs ───────────────────────────────────────────────
  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _filterTab('All', 'all'),
          const SizedBox(width: 8),
          _filterTab('Diet Assigned', 'diet_assigned'),
          const SizedBox(width: 8),
          _filterTab('No Diet Plan', 'no_diet'),
        ],
      ),
    );
  }

  Widget _filterTab(String label, String value) {
    final isActive = _dietFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _dietFilter = value);
        _applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Member Card ───────────────────────────────────────────────
  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] ?? '';
    final slot = member['training_slot'] ?? '';
    final plan = member['plan'] ?? '';
    final planDuration = member['plan_duration'];
    final rawStatus = (member['membership_status'] ?? 'pending')
        .toString()
        .toLowerCase();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hasDietPlan = member['diet_plan_id'] != null;
    final dietTitle = member['diet_plan_title'] ?? '';
    final dietPlanId = member['diet_plan_id'];
    final progress = _progressPercent(member);

    // Status badge
    Color badgeBg;
    String badgeLabel;
    switch (rawStatus) {
      case 'active':
        badgeBg = AppTheme.active;
        badgeLabel = 'active';
        break;
      case 'expired':
      case 'frozen':
        badgeBg = AppTheme.textSecondary;
        badgeLabel = 'inactive';
        break;
      default:
        badgeBg = AppTheme.pending;
        badgeLabel = 'pending';
    }

    // Plan label
    String planLabel = '';
    if (plan.isNotEmpty) {
      planLabel = planDuration != null ? '$plan ${planDuration} Days' : plan;
    }

    // Workout + slot label
    final workoutType = member['workout_type'] ?? '';
    final slotLabel = slot.isNotEmpty
        ? '${workoutType.isNotEmpty ? workoutType : slot[0].toUpperCase() + slot.substring(1)} (${_slotTime(slot)})'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + Name + Icons ──────────────────────────
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badgeLabel,
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
                // Eye + Edit icons
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        '/trainer/member-profile',
                        arguments: member,
                      ),
                      child: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        '/trainer/diet-plan-form',
                        arguments: {'member': member, 'plan_id': dietPlanId},
                      )?.then((_) => _loadMembers()),
                      child: Icon(
                        hasDietPlan ? Icons.edit_outlined : Icons.add,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Info rows ──────────────────────────────────────
            if (slotLabel.isNotEmpty)
              _infoRow(Icons.access_time_outlined, slotLabel),
            if (planLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              _infoRow(Icons.people_outline, planLabel),
            ],

            // ── Diet plan badge ────────────────────────────────
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu_outlined,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasDietPlan
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hasDietPlan ? dietTitle : 'No Diet Plan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasDietPlan
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Progress Bar ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: AppTheme.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Action Buttons ─────────────────────────────────
            Row(
              children: [
                // View Details — white outlined
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(
                      '/trainer/member-profile',
                      arguments: member,
                    ),
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                    label: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.border),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Edit/Create Diet Plan
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(
                      '/trainer/diet-plan-form',
                      arguments: {'member': member, 'plan_id': dietPlanId},
                    )?.then((_) => _loadMembers()),
                    icon: Icon(
                      hasDietPlan ? Icons.edit_outlined : Icons.add,
                      size: 16,
                    ),
                    label: Text(
                      hasDietPlan ? 'Edit Diet Plan' : 'Create Diet Plan',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasDietPlan
                          ? Colors.green
                          : AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _slotTime(String slot) {
    switch (slot.toLowerCase()) {
      case 'morning':
        return '6:00 AM';
      case 'midday':
        return '12:00 PM';
      case 'evening':
        return '6:00 PM';
      case 'night':
        return '8:00 PM';
      default:
        return slot;
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'No members found',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Members assigned to you will appear here',
            style: TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
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
              _navItem(Icons.people_outline_rounded, 'Members', isActive: true),
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

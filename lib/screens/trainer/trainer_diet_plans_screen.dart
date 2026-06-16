import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerDietPlansScreen extends StatefulWidget {
  @override
  State<TrainerDietPlansScreen> createState() => _TrainerDietPlansScreenState();
}

class _TrainerDietPlansScreenState extends State<TrainerDietPlansScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _filtered = [];
  final _searchController = TextEditingController();
  Map<String, dynamic> _stats = {
    'totalPlans': 0,
    'activePlans': 0,
    'noPlan': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    final result = await TrainerService.getDietPlans();
    if (result['success']) {
      _plans = List<Map<String, dynamic>>.from(result['plans']);
      _stats = Map<String, dynamic>.from(result['stats']);
      _filtered = List.from(_plans);
    }
    setState(() => _isLoading = false);
  }

  void _applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_plans);
      } else {
        _filtered = _plans.where((p) {
          final title = (p['title'] ?? '').toString().toLowerCase();
          final member = (p['member_name'] ?? '').toString().toLowerCase();
          return title.contains(query.toLowerCase()) ||
              member.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deletePlan(int planId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Delete Diet Plan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expired,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final result = await TrainerService.deleteDietPlan(planId);
      if (result['success']) {
        Get.snackbar(
          'Deleted',
          'Diet plan deleted successfully',
          backgroundColor: AppTheme.active,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        _loadPlans();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed',
          backgroundColor: AppTheme.expired,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
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
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _loadPlans,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title + New Plan ─────────────────
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Diet Plans',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${_stats['activePlans']} active plans',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () => Get.toNamed(
                                  '/trainer/diet-plan-form',
                                  arguments: {'member': null, 'plan_id': null},
                                )?.then((_) => _loadPlans()),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(
                                  'New Plan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Stats Row ────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.restaurant_menu_outlined,
                                  iconBg: Colors.green,
                                  value: '${_stats['totalPlans']}',
                                  label: 'Total Plans',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.check_circle_outline,
                                  iconBg: Colors.blue,
                                  value: '${_stats['activePlans']}',
                                  label: 'Active',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.access_time_outlined,
                                  iconBg: Colors.orange,
                                  value: '${_stats['noPlan']}',
                                  label: 'No Plan',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Search ───────────────────────────
                          TextField(
                            controller: _searchController,
                            onChanged: _applySearch,
                            decoration: InputDecoration(
                              hintText: 'Search by member or plan name...',
                              hintStyle: const TextStyle(
                                color: AppTheme.textHint,
                                fontSize: 14,
                              ),
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
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: AppTheme.border,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                borderSide: const BorderSide(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Plan Cards ───────────────────────
                          if (_filtered.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu_outlined,
                                      size: 56,
                                      color: AppTheme.textHint,
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'No diet plans yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Tap "New Plan" to create one',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ..._filtered.map((p) => _buildPlanCard(p)).toList(),
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

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final planId = plan['id'];
    final title = plan['title'] ?? '';
    final memberName = plan['member_name'] ?? '';
    final pkgName = plan['package_name'] ?? '';
    final pkgDur = plan['package_duration'];
    final status = (plan['membership_status'] ?? 'pending')
        .toString()
        .toLowerCase();
    final assignDate = plan['assignment_date'] != null
        ? plan['assignment_date'].toString().split('T')[0]
        : '';
    final breakfast = plan['breakfast'] ?? '';
    final lunch = plan['lunch'] ?? '';
    final dinner = plan['dinner'] ?? '';
    final snacks = plan['snacks'] ?? '';

    // Build meal tags (first item of each meal)
    final List<String> tags = [];
    void addTag(String meal) {
      final first = meal.split('\n').first.trim();
      if (first.isNotEmpty) tags.add(first);
    }

    addTag(breakfast);
    addTag(lunch);
    addTag(dinner);
    addTag(snacks);

    final pkgLabel = pkgName.isNotEmpty
        ? (pkgDur != null ? '$pkgName ${pkgDur} Days' : pkgName)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + status badge ──────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu_outlined,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          memberName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (pkgLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            pkgLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? AppTheme.active
                      : AppTheme.textSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status == 'active' ? 'Active' : 'Inactive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Meal tags ─────────────────────────────────────
          if (tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (assignDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Assigned: $assignDate',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // ── Action buttons ────────────────────────────────
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Get.toNamed(
                  '/trainer/member-profile',
                  arguments: {'id': plan['member_id'], 'name': memberName},
                ),
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                label: const Text(
                  'View Member',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.border),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(
                  '/trainer/diet-plan-form',
                  arguments: {'plan_id': planId, 'member': null},
                )?.then((_) => _loadPlans()),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text(
                  'Edit Plan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _deletePlan(planId, title),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.expired,
                  size: 22,
                ),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                Icons.restaurant_menu_outlined,
                'Diet Plans',
                isActive: true,
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

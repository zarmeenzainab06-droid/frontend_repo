import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerMembersScreen extends StatefulWidget {
  @override
  State<TrainerMembersScreen> createState() => _TrainerMembersScreenState();
}

class _TrainerMembersScreenState extends State<TrainerMembersScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _filtered = [];

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
      _filtered = List.from(_members);
    }
    setState(() => _isLoading = false);
  }

  void _applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_members);
      } else {
        _filtered = _members.where((m) {
          final name = (m['name'] ?? '').toString().toLowerCase();
          final email = (m['email'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase());
        }).toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TrainerDrawer(), // ✅ add this line
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildTopBar(),
          _buildHeader(),
          _buildSearchBar(),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Text(
            'My Members',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

  // ── Member Card ───────────────────────────────────────────────
  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] ?? '';
    final email = member['email'] ?? '';
    final phone = member['phone'] ?? 'N/A';
    final slot = member['training_slot'] ?? '';
    final plan = member['plan'] ?? 'N/A';
    final rawStatus = (member['membership_status'] ?? 'pending')
        .toString()
        .toLowerCase();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Status badge colors
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
          // ── Avatar + Name + Status badge ──────────────────
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
                child: Row(
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
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Info rows ──────────────────────────────────────
          _infoRow(Icons.email_outlined, email),
          const SizedBox(height: 6),
          _infoRow(Icons.phone_outlined, phone.isNotEmpty ? phone : 'N/A'),
          const SizedBox(height: 6),
          _infoRow(
            Icons.access_time_outlined,
            slot.isNotEmpty ? _slotLabel(slot) : 'No slot assigned',
          ),
          const SizedBox(height: 6),
          _infoRow(
            Icons.card_membership_outlined,
            'Package: ${plan.isNotEmpty ? plan : 'N/A'}',
          ),
          const SizedBox(height: 14),

          // ── Action Buttons ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Get.toNamed('/trainer/member-profile', arguments: member),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Contact',
                      'Call $name on $phone',
                      backgroundColor: AppTheme.surface,
                      colorText: AppTheme.textPrimary,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.border),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: const Text(
                    'Contact',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  // ── Empty State ───────────────────────────────────────────────
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
              _navItem(Icons.people_outline_rounded, 'Members', isActive: true),
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

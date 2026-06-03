import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerProfileScreen extends StatefulWidget {
  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final box = GetStorage();
  bool _isLoading = true;

  // ── Real data from API ─────────────────────────────────────
  String _name = '';
  String _email = '';
  String _phone = 'N/A';
  String _specialty = '';
  String _joinedDate = '';
  int _experienceYears = 0;
  int _assignedMembers = 0;
  int _sessionsCompleted = 0;
  List<String> _certifications = [];

  String get _initial => _name.isNotEmpty ? _name[0].toUpperCase() : 'T';

  String get _experienceLabel =>
      '$_experienceYears Year${_experienceYears == 1 ? '' : 's'} Experience';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final result = await TrainerService.getProfile();

    if (result['success']) {
      final p = result['profile'];
      setState(() {
        _name = p['name'] ?? '';
        _email = p['email'] ?? '';
        _phone = p['phone'] ?? 'N/A';
        _specialty = p['specialty'] ?? 'Fitness Trainer';
        _joinedDate = p['joinedDate'] ?? '';
        _experienceYears = p['experienceYears'] ?? 0;
        _assignedMembers = p['assignedMembers'] ?? 0;
        _sessionsCompleted = p['sessionsCompleted'] ?? 0;
        _certifications = List<String>.from(p['certifications'] ?? []);
      });
    } else {
      // Fallback to stored user data if API fails
      final user = box.read('user');
      if (user != null) {
        setState(() {
          _name = user['name'] ?? '';
          _email = user['email'] ?? '';
        });
      }
    }

    setState(() => _isLoading = false);
  }

  void _logout() {
    box.remove('token');
    box.remove('user');
    box.remove('role');
    box.remove('isLoggedIn');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _loadProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title ──────────────────────────
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Red Profile Card ───────────────
                          _buildProfileCard(),
                          const SizedBox(height: 14),

                          // ── Stats ──────────────────────────
                          _buildStatCard(
                            icon: Icons.people_alt_rounded,
                            iconBg: Colors.blue,
                            value: '$_assignedMembers',
                            label: 'Assigned Members',
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: Icons.fitness_center_rounded,
                            iconBg: Colors.green,
                            value: '$_sessionsCompleted',
                            label: 'Sessions Completed',
                          ),
                          const SizedBox(height: 12),

                          // ── Joined Date ────────────────────
                          _buildJoinedCard(),
                          const SizedBox(height: 14),

                          // ── Contact Info ───────────────────
                          _buildContactCard(),
                          const SizedBox(height: 14),

                          // ── Certifications ─────────────────
                          if (_certifications.isNotEmpty) ...[
                            _buildCertificationsCard(),
                            const SizedBox(height: 14),
                          ],

                          // ── Action Buttons ─────────────────
                          _buildActionButtons(context),
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
  Widget _buildTopBar(BuildContext context) {
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
          // Avatar
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

          // Name
          Text(
            _name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Specialty
          Text(
            _specialty,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Experience badge
          if (_experienceYears > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _experienceLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Stat Card ─────────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required String value,
    required String label,
  }) {
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
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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

  // ── Contact Information Card ──────────────────────────────────
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
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.fitness_center_outlined,
            label: 'Specialization',
            value: _specialty,
          ),
        ],
      ),
    );
  }

  // ── Certifications Card ───────────────────────────────────────
  Widget _buildCertificationsCard() {
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
            'Certifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _certifications.map((cert) => _certBadge(cert)).toList(),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          _actionButton(
            label: 'Edit Profile',
            isFirst: true,
            onTap: () => Get.snackbar(
              'Coming Soon',
              'Edit profile will be available soon',
              backgroundColor: AppTheme.surface,
              colorText: AppTheme.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            ),
          ),
          Divider(height: 1, color: AppTheme.border),
          _actionButton(
            label: 'Change Password',
            onTap: () => Get.snackbar(
              'Coming Soon',
              'Change password will be available soon',
              backgroundColor: AppTheme.surface,
              colorText: AppTheme.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            ),
          ),
          Divider(height: 1, color: AppTheme.border),
          _actionButton(
            label: 'View Schedule History',
            onTap: () => Get.snackbar(
              'Coming Soon',
              'Schedule history will be available soon',
              backgroundColor: AppTheme.surface,
              colorText: AppTheme.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            ),
          ),
          Divider(height: 1, color: AppTheme.border),

          // Logout
          InkWell(
            onTap: () => _confirmLogout(context),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.radiusLg),
              bottomRight: Radius.circular(AppTheme.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout_rounded, color: AppTheme.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _certBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 13,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isFirst
          ? const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLg),
              topRight: Radius.circular(AppTheme.radiusLg),
            )
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            child: const Text('Logout'),
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
              _navItem(
                Icons.people_outline_rounded,
                'Members',
                onTap: () => Get.offNamed('/trainer/members'),
              ),
              _navItem(
                Icons.calendar_month_outlined,
                'Schedule',
                onTap: () => Get.toNamed('/trainer/schedule'),
              ),
              _navItem(Icons.person_rounded, 'Profile', isActive: true),
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

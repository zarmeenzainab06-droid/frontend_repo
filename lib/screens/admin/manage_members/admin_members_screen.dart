import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/utils/theme.dart';
import '../../../core/widgets/app_shell.dart';
import 'member_form_page.dart';

class AdminMembersScreen extends StatefulWidget {
  @override
  State<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends State<AdminMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _filtered = [];
  String _statusFilter = 'All Status';

  final List<String> _statusOptions = [
    'All Status',
    'Active',
    'Expired',
    'Frozen',
  ];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final result = await AdminService.getAllMembers(
      search: _searchController.text,
    );
    if (result['success']) {
      _members = List<Map<String, dynamic>>.from(result['members']);
      _applyFilter();
    }
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    setState(() {
      if (_statusFilter == 'All Status') {
        _filtered = List.from(_members);
      } else {
        _filtered = _members.where((m) {
          final status = (m['membership_status'] ?? '')
              .toString()
              .toLowerCase();
          return status == _statusFilter.toLowerCase();
        }).toList();
      }
    });
  }

  // ---------- color helpers (kept self-contained, built on AppTheme.primary) ----------
  Color _lighten(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'expired':
        return Icons.cancel_rounded;
      case 'frozen':
        return Icons.ac_unit_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  // Overrides only 'frozen' (which was rendering grey from
  // AppColors.statusColor/statusLightColor) with a distinct sky-blue tone.
  // Every other status keeps using your existing theme colors untouched.
  Color _statusColor(String status) {
    if (status == 'frozen') return const Color(0xFF0EA5E9);
    return AppColors.statusColor(status);
  }

  Color _statusBgColor(String status) {
    if (status == 'frozen') return const Color(0xFFE0F2FE);
    return AppColors.statusLightColor(status);
  }

  Future<void> _deleteMember(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.94),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.expired.withOpacity(0.85),
                          AppTheme.expired,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.expired.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Delete Member',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to delete "$name"? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _outlineActionButton(
                          icon: Icons.close_rounded,
                          label: 'Cancel',
                          color: AppTheme.textSecondary,
                          onTap: () => Navigator.pop(ctx, false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _gradientActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          colors: [
                            AppTheme.expired,
                            _darken(AppTheme.expired, 0.1),
                          ],
                          onTap: () => Navigator.pop(ctx, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirm == true) {
      final result = await AdminService.deleteMember(id);
      if (result['success']) {
        Get.snackbar(
          'Deleted',
          '$name has been removed',
          backgroundColor: AppTheme.active,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        _loadMembers();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to delete member',
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
    return AppShell(
      role: 'admin',
      subtitle: 'Admin Panel',
      bottomNav: const AdminBottomNav(activeIndex: 1),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  _buildHeader(),
                  // Reserves room below the header so the floating card
                  // below is fully inside the Stack's hit-testable area
                  // (a negative-overflow Positioned would visually overlap
                  // but silently eat taps on the part that pokes out).
                  const SizedBox(height: 70),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: _buildSearchFilterCard(),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
    );
  }

  // ---------- header (gradient hero) ----------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 58),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _darken(AppTheme.primary, 0.18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -28,
            top: -34,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 54,
            top: 64,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEMBERS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Manage Members',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_members.length} total members',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _GlassButton(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemberFormPage()),
                  );
                  if (result == true) await _loadMembers();
                },
                icon: Icons.add_rounded,
                label: 'Add',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- floating glass search + filter chip card ----------
  Widget _buildSearchFilterCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => _loadMembers(),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppTheme.textHint,
                size: 20,
              ),
              filled: true,
              fillColor: AppTheme.background,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final option = _statusOptions[i];
                final selected = option == _statusFilter;
                return GestureDetector(
                  onTap: () {
                    setState(() => _statusFilter = option);
                    _applyFilter();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: [
                                AppTheme.primary,
                                _lighten(AppTheme.primary, 0.08),
                              ],
                            )
                          : null,
                      color: selected ? null : AppTheme.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? Colors.transparent : AppTheme.border,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- member card ----------
  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] ?? '';
    final email = member['email'] ?? '';
    final phone = member['phone'] ?? '';
    final packageName = (member['package_name'] ?? '').toString();
    final endDate = member['end_date'] ?? '';
    final trainer = member['trainer_name'] ?? '';
    final rawStatus = (member['membership_status'] ?? 'no plan')
        .toString()
        .toLowerCase();
    final duration = member['package_duration']?.toString() ?? '';
    final fee = member['amount_received'];
    final feeStr = fee != null
        ? 'PKR ${double.tryParse(fee.toString())?.toStringAsFixed(0) ?? fee}'
        : '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final statusColor = _statusColor(rawStatus);
    final statusBg = _statusBgColor(rawStatus);
    final planLabel = packageName.isNotEmpty
        ? '$packageName${duration.isNotEmpty ? ' ($duration days)' : ''}${feeStr.isNotEmpty ? ' • $feeStr' : ''}'
        : 'No plan assigned';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.35),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.4)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(21),
                  topRight: Radius.circular(21),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary,
                              _lighten(AppTheme.primary, 0.12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _statusIcon(rawStatus),
                              size: 12,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rawStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.email_outlined, email),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.phone_outlined,
                          phone.isNotEmpty ? phone : 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(Icons.card_membership_outlined, planLabel),
                        if (endDate.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _infoRow(
                            Icons.calendar_today_outlined,
                            'Expires: ${endDate.toString().split('T')[0]}',
                          ),
                        ],
                        if (trainer.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _infoRow(Icons.person_outline, 'Trainer: $trainer'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (rawStatus == 'active' || rawStatus == 'frozen') ...[
                    SizedBox(
                      width: double.infinity,
                      child: _gradientActionButton(
                        icon: rawStatus == 'frozen'
                            ? Icons.play_circle_outline_rounded
                            : Icons.pause_circle_outline_rounded,
                        label: rawStatus == 'frozen'
                            ? 'Unfreeze Membership'
                            : 'Freeze Membership',
                        colors: rawStatus == 'frozen'
                            ? [const Color(0xFF38BDF8), const Color(0xFF0EA5E9)]
                            : [
                                const Color(0xFFFB923C),
                                const Color(0xFFEA580C),
                              ],
                        onTap: () async {
                          final action = rawStatus == 'frozen'
                              ? 'unfreeze'
                              : 'freeze';
                          final result = await AdminService.freezeMembership(
                            userId: member['id'],
                            action: action,
                          );
                          if (result['success'] == true) {
                            Get.snackbar(
                              'Success',
                              'Membership ${action}d successfully',
                              backgroundColor: AppTheme.active,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                            _loadMembers();
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
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _gradientActionButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          colors: [
                            AppTheme.primary,
                            _lighten(AppTheme.primary, 0.1),
                          ],
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MemberFormPage(memberId: member['id']),
                              ),
                            );
                            if (result == true) await _loadMembers();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _outlineActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          color: AppTheme.expired,
                          onTap: () => _deleteMember(member['id'], name),
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
    );
  }

  // ---------- shared small widgets ----------
  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: AppTheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradientActionButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlineActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.15),
                  AppTheme.primary.withOpacity(0.03),
                ],
              ),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 44,
              color: AppTheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No members found',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _statusFilter != 'All Status'
                ? 'Try changing the status filter'
                : 'Add your first member',
            style: const TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}

/// Frosted-glass pill button used in the gradient header (e.g. "Add" member).
class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  const _GlassButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

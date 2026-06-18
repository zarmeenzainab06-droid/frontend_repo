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

  void _showStatusFilter(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<String>(
      context: context,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      elevation: 8,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height + 4,
        offset.dx + button.size.width,
        0,
      ),
      items: _statusOptions.map((option) {
        final isSelected = option == _statusFilter;
        return PopupMenuItem<String>(
          value: option,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 16, color: AppTheme.primary),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() => _statusFilter = value);
        _applyFilter();
      }
    });
  }

  Future<void> _deleteMember(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Delete Member',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
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
              minimumSize: const Size(80, 40),
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
          _buildSearchAndFilter(),
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

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manage\nMembers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemberFormPage()),
                  );
                  if (result == true) await _loadMembers();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Member',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (val) => _loadMembers(),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.textHint,
                size: 20,
              ),
              filled: true,
              fillColor: AppTheme.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                size: 18,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => _showStatusFilter(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _statusFilter,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] ?? '';
    final email = member['email'] ?? '';
    final phone = member['phone'] ?? '';
    final packageName = (member['package_name'] ?? '').toString();
    final endDate = member['end_date'] ?? '';
    final trainer = member['trainer_name'] ?? '';
    // final rawStatus = (member['membership_status'] ?? 'pending')
    final rawStatus = (member['membership_status'] ?? 'no plan')
        .toString()
        .toLowerCase();
    final duration = member['package_duration']?.toString() ?? '';
    final fee = member['membership_fee'];
    final feeStr = fee != null
        ? 'PKR ${double.tryParse(fee.toString())?.toStringAsFixed(0) ?? fee}'
        : '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final statusColor = AppColors.statusColor(rawStatus);
    final statusBg = AppColors.statusLightColor(rawStatus);
    final planLabel = packageName.isNotEmpty
        ? '$packageName${duration.isNotEmpty ? ' ($duration days)' : ''}${feeStr.isNotEmpty ? ' • $feeStr' : ''}'
        : 'No plan assigned';

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
            Row(
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rawStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 10),
            _infoRow(Icons.email_outlined, email),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, phone.isNotEmpty ? phone : 'N/A'),
            const SizedBox(height: 6),
            _infoRow(Icons.card_membership_outlined, planLabel),
            if (endDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(
                Icons.calendar_today_outlined,
                'Expires: ${endDate.toString().split('T')[0]}',
              ),
            ],
            if (trainer.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.person_outline, 'Trainer: $trainer'),
            ],
            const SizedBox(height: 14),
            //forrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr frozen button
            if (rawStatus == 'active' || rawStatus == 'frozen') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: rawStatus == 'frozen'
                        ? const Color.fromARGB(255, 135, 206, 235)
                        : AppTheme.frozen,
                    side: BorderSide(
                      color: rawStatus == 'frozen'
                          ? const Color.fromARGB(255, 135, 206, 235)
                          : const Color.fromARGB(255, 185, 24, 24),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () async {
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
                      _loadMembers(); // refresh list
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
                  icon: Icon(
                    rawStatus == 'frozen'
                        ? Icons.play_circle_outline
                        : Icons.pause_circle_outline,
                    size: 18,
                  ),
                  label: Text(
                    rawStatus == 'frozen'
                        ? 'Unfreeze Membership'
                        : 'Freeze Membership',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MemberFormPage(memberId: member['id']),
                        ),
                      );
                      if (result == true) await _loadMembers();
                    },

                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.expired,
                      side: const BorderSide(color: AppTheme.expired),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => _deleteMember(member['id'], name),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
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

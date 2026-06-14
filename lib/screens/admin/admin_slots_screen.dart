import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/admin_slot_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/app_shell.dart';
import '../admin/slot_form_page.dart';
import '../admin/slot_member_screen.dart';

class AdminSlotsScreen extends StatefulWidget {
  const AdminSlotsScreen({super.key});

  @override
  State<AdminSlotsScreen> createState() => _AdminSlotsScreenState();
}

class _AdminSlotsScreenState extends State<AdminSlotsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];
  List<Map<String, dynamic>> _filtered = [];
  String _statusFilter = 'All Status';

  final List<String> _statusOptions = [
    'All Status',
    'Active',
    'Inactive',
    'Full',
  ];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    final result = await AdminService.getAllSlots(
      search: _searchController.text,
    );
    if (result['success']) {
      _slots = List<Map<String, dynamic>>.from(result['slots']);
      _applyFilter();
    }
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    setState(() {
      if (_statusFilter == 'All Status') {
        _filtered = List.from(_slots);
      } else if (_statusFilter == 'Full') {
        _filtered = _slots.where((s) {
          final assigned = int.tryParse(s['assigned_members'].toString()) ?? 0;
          final capacity = int.tryParse(s['capacity'].toString()) ?? 0;
          return capacity > 0 && assigned >= capacity;
        }).toList();
      } else {
        _filtered = _slots.where((s) {
          return (s['status'] ?? '').toString().toLowerCase() ==
              _statusFilter.toLowerCase();
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

  Future<void> _deleteSlot(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Delete Slot',
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
      final result = await AdminService.deleteSlot(id);
      if (result['success']) {
        Get.snackbar(
          'Deleted',
          '$name has been removed',
          backgroundColor: AppTheme.active,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        _loadSlots();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to delete slot',
          backgroundColor: AppTheme.expired,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  String _slotStatusLabel(Map<String, dynamic> slot) {
    final status = (slot['status'] ?? '').toString().toLowerCase();
    final assigned = int.tryParse(slot['assigned_members'].toString()) ?? 0;
    final capacity = int.tryParse(slot['capacity'].toString()) ?? 0;
    if (status == 'inactive') return 'inactive';
    if (capacity > 0 && assigned >= capacity) return 'full';
    return 'active';
  }

  Color _slotStatusColor(String label) {
    switch (label) {
      case 'active':
        return AppTheme.active;
      case 'full':
        return AppTheme.pending;
      case 'inactive':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _slotStatusBg(String label) {
    switch (label) {
      case 'active':
        return AppTheme.activeLight;
      case 'full':
        return AppTheme.pendingLight;
      case 'inactive':
        return AppTheme.background;
      default:
        return AppTheme.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: 'admin',
      subtitle: 'Admin Panel',
      bottomNav: const AdminBottomNav(activeIndex: 2),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : _filtered.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _loadSlots,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _buildSlotCard(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Time\nSlots',
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
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SlotFormPage()),
                  );
                  if (result == true) await _loadSlots();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Slot',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (_) => _loadSlots(),
            decoration: InputDecoration(
              hintText: 'Search by slot name...',
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

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    final id = slot['id'];
    final name = slot['name'] ?? '';
    final startTime = slot['start_time'] ?? '';
    final endTime = slot['end_time'] ?? '';
    final capacity = int.tryParse(slot['capacity'].toString()) ?? 0;
    final assigned = int.tryParse(slot['assigned_members'].toString()) ?? 0;
    final statusLabel = _slotStatusLabel(slot);
    final statusColor = _slotStatusColor(statusLabel);
    final statusBg = _slotStatusBg(statusLabel);
    final progress = capacity > 0 ? (assigned / capacity).clamp(0.0, 1.0) : 0.0;

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
            // ── Header row ──
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$startTime – $endTime',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
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
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 12),

            // ── Capacity row ──
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$assigned / $capacity members',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}% full',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: progress >= 1.0
                        ? AppTheme.expired
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? AppTheme.expired
                      : progress >= 0.8
                      ? AppTheme.pending
                      : AppTheme.active,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Action buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      minimumSize: const Size(0, 38),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            SlotMembersSheet(slotId: id, slotName: name),
                      );
                    },
                    icon: const Icon(Icons.people_outline, size: 15),
                    label: const Text(
                      'Members',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      minimumSize: const Size(0, 38),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SlotFormPage(slotId: id),
                        ),
                      );
                      if (result == true) await _loadSlots();
                    },
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.expired,
                    side: const BorderSide(color: AppTheme.expired),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    minimumSize: const Size(42, 38),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _deleteSlot(id, name),
                  child: const Icon(Icons.delete_outline, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_outlined, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text(
            'No slots found',
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
                : 'Add your first time slot',
            style: const TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}

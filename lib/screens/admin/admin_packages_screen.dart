import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';

class AdminPackagesScreen extends StatefulWidget {
  @override
  State<AdminPackagesScreen> createState() => _AdminPackagesScreenState();
}

class _AdminPackagesScreenState extends State<AdminPackagesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _allSlots = []; // every slot from DB

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      AdminService.getPackages(),
      AdminService.getSlots(activeOnly: false),
    ]);
    if (results[0]['success']) {
      setState(
        () =>
            _packages = List<Map<String, dynamic>>.from(results[0]['packages']),
      );
    }
    if (results[1]['success']) {
      setState(
        () => _allSlots = List<Map<String, dynamic>>.from(results[1]['slots']),
      );
    }
    setState(() => _isLoading = false);
  }

  // ── Add / Edit bottom sheet ──────────────────────────────────
  void _showPackageSheet({Map<String, dynamic>? package}) {
    final isEdit = package != null;
    final nameCtrl = TextEditingController(text: package?['name'] ?? '');
    final durationCtrl = TextEditingController(
      text: package?['duration']?.toString() ?? '',
    );
    final priceCtrl = TextEditingController(
      text: package?['price']?.toString() ?? '',
    );
    final descCtrl = TextEditingController(text: package?['description'] ?? '');

    // Pre-populate selected slot ids from existing package slots
    final existingSlots = List<Map<String, dynamic>>.from(
      package?['slots'] ?? [],
    );
    final Set<int> selectedSlotIds = existingSlots
        .map<int>((s) => s['id'] as int)
        .toSet();

    bool isActive = (package?['is_active'] ?? 1) == 1;
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusXl),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEdit ? 'Edit Package' : 'Add New Package',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sheetLabel('Package Name *'),
                    _sheetField(
                      controller: nameCtrl,
                      hint: 'e.g. Gold, Silver, Platinum',
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    _sheetLabel('Duration (days) *'),
                    _sheetField(
                      controller: durationCtrl,
                      hint: 'e.g. 30, 90, 180',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Duration is required';
                        if (int.tryParse(v) == null)
                          return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _sheetLabel('Price (\$) *'),
                    _sheetField(
                      controller: priceCtrl,
                      hint: 'e.g. 99.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'Price is required';
                        if (double.tryParse(v) == null)
                          return 'Enter a valid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _sheetLabel('Description'),
                    _sheetField(
                      controller: descCtrl,
                      hint: 'Brief description of what is included',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),

                    // ── Multi-select slots ─────────────────────────────
                    _sheetLabel('Time Slots (select one or more)'),
                    if (_allSlots.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: const Text(
                          'No slots available — create slots first',
                          style: TextStyle(
                            color: AppTheme.textHint,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: Column(
                          children: _allSlots.map((slot) {
                            final slotId = slot['id'] as int;
                            final isChecked = selectedSlotIds.contains(slotId);
                            final label = slot['name'] ?? '';
                            final time =
                                '${slot['start_time'] ?? ''} – ${slot['end_time'] ?? ''}';
                            return CheckboxListTile(
                              dense: true,
                              activeColor: AppTheme.primary,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              title: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              value: isChecked,
                              onChanged: (val) {
                                setSheet(() {
                                  if (val == true) {
                                    selectedSlotIds.add(slotId);
                                  } else {
                                    selectedSlotIds.remove(slotId);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Active toggle
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Inactive packages won\'t appear in dropdown',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isActive,
                          activeColor: AppTheme.primary,
                          onChanged: (val) => setSheet(() => isActive = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheet(() => isSaving = true);

                                final data = {
                                  'name': nameCtrl.text.trim(),
                                  'duration': int.parse(
                                    durationCtrl.text.trim(),
                                  ),
                                  'price': double.parse(priceCtrl.text.trim()),
                                  'description': descCtrl.text.trim(),
                                  'is_active': isActive ? 1 : 0,
                                  // send as list of ints
                                  'slot_ids': selectedSlotIds.toList(),
                                };

                                final result = isEdit
                                    ? await AdminService.updatePackage(
                                        id: package!['id'],
                                        data: data,
                                      )
                                    : await AdminService.createPackage(data);

                                setSheet(() => isSaving = false);

                                if (result['success']) {
                                  Navigator.pop(ctx);
                                  Get.snackbar(
                                    'Success',
                                    isEdit
                                        ? 'Package updated'
                                        : 'Package created',
                                    backgroundColor: AppTheme.active,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                    margin: const EdgeInsets.all(16),
                                  );
                                  _loadData();
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    result['message'] ?? 'Something went wrong',
                                    backgroundColor: AppTheme.expired,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(16),
                                  );
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'Update Package' : 'Create Package',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Delete ───────────────────────────────────────────────────
  Future<void> _deletePackage(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Delete Package',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Delete "$name"? Members with this package won\'t be affected but it will be removed from the dropdown.',
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
      final result = await AdminService.deletePackage(id);
      if (result['success']) {
        Get.snackbar(
          'Deleted',
          '$name has been removed',
          backgroundColor: AppTheme.active,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        _loadData();
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

  // ── Toggle active ────────────────────────────────────────────
  Future<void> _toggleActive(Map<String, dynamic> pkg) async {
    final newVal = (pkg['is_active'] == 1) ? 0 : 1;
    final slots = List<Map<String, dynamic>>.from(pkg['slots'] ?? []);
    final slotIds = slots.map<int>((s) => s['id'] as int).toList();
    await AdminService.updatePackage(
      id: pkg['id'],
      data: {
        'name': pkg['name'],
        'duration': pkg['duration'],
        'price': pkg['price'],
        'description': pkg['description'] ?? '',
        'is_active': newVal,
        'slot_ids': slotIds,
      },
    );
    _loadData();
  }

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : _packages.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _packages.length,
                      itemBuilder: (ctx, i) => _buildPackageCard(_packages[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showPackageSheet(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Package',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 4,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _darken(AppTheme.primary, 0.18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'GymFitex',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage Packages',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> pkg) {
    final name = pkg['name'] ?? '';
    final duration = pkg['duration'] ?? 0;
    final price = pkg['price'] ?? 0;
    final description = pkg['description'] ?? '';
    final isActive = (pkg['is_active'] ?? 1) == 1;
    final slots = List<Map<String, dynamic>>.from(pkg['slots'] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
        border: Border.all(
          color: isActive ? Colors.transparent : AppTheme.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryLight
                        : AppTheme.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.card_membership_outlined,
                    color: isActive ? AppTheme.primary : AppTheme.textSecondary,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '$duration days • \$$price',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleActive(pkg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.activeLight
                          : AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppTheme.active : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppTheme.active
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],

            // ── Slots chips ──────────────────────────────────────
            if (slots.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: slots.map((s) {
                  final sName = s['name'] ?? '';
                  final start = s['start_time'] ?? '';
                  final end = s['end_time'] ?? '';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          start.isNotEmpty && end.isNotEmpty
                              ? '$sName ($start–$end)'
                              : sName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 14),

            // Action buttons
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
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => _showPackageSheet(package: pkg),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text(
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
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.expired,
                      side: const BorderSide(color: AppTheme.expired),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => _deletePackage(pkg['id'], name),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text(
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'No packages yet',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to add your first package',
            style: TextStyle(fontSize: 13, color: AppTheme.textHint),
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
                onTap: () => Get.offNamed('/admin-dashboard'),
              ),
              _navItem(
                Icons.people_outline,
                'Members',
                onTap: () => Get.offNamed('/admin/members'),
              ),
              _navItem(
                Icons.bar_chart_outlined,
                'Reports',
                onTap: () => Get.toNamed('/admin/reports'),
              ),
              _navItem(
                Icons.person_outline,
                'Profile',
                onTap: () => Get.toNamed('/admin/profile'),
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

  Widget _sheetLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        filled: true,
        fillColor: AppTheme.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.expired, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.expired, width: 1.5),
        ),
      ),
    );
  }
}

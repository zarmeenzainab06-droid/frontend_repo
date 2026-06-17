import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/utils/theme.dart';
import '../../../core/widgets/app_shell.dart';
import 'trainer_form_page.dart';

class AdminTrainersScreen extends StatefulWidget {
  const AdminTrainersScreen({super.key});

  @override
  State<AdminTrainersScreen> createState() => _AdminTrainersScreenState();
}

class _AdminTrainersScreenState extends State<AdminTrainersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _trainers = [];
  List<Map<String, dynamic>> _filtered = [];

  String _slotFilter = 'all';

  final List<String> _slotOptions = [
    'all',
    'morning',
    'midday',
    'evening',
    'night',
  ];

  String _slotLabel(String value) {
    switch (value) {
      case 'morning':
        return 'Morning';
      case 'midday':
        return 'Midday';
      case 'evening':
        return 'Evening';
      case 'night':
        return 'Night';
      default:
        return 'All Slots';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    setState(() => _isLoading = true);
    final result = await AdminService.getAllTrainers(
      search: _searchController.text,
    );
    print("API RESULT: $result");
    print("TRAINERS FROM API: ${result['trainers']}");
    if (result['success']) {
      // BUG FIX 1 & 2: Set _trainers first, THEN call _applyFilter.
      // Previously _applyFilter was called inside a setState that also set
      // _isLoading, meaning _trainers hadn't been updated in the local variable
      // yet when _applyFilter read it. Now we set _trainers synchronously and
      // call _applyFilter after so it always sees fresh data.
      _trainers = List<Map<String, dynamic>>.from(result['trainers']);
      print("TRAINERS STATE: $_trainers");
    } else {
      _trainers = [];
    }

    // BUG FIX 3 (slot filter): _applyFilter uses the current _slotFilter value
    // which is preserved in state — we never reset it here, so the user's
    // chosen filter survives every reload triggered by search or pull-to-refresh.
    // _applyFilter();

    // setState(() => _isLoading = false);
    setState(() {
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    print("FILTER SELECTED: $_slotFilter");
    print("BEFORE FILTER: $_trainers");
    // This runs synchronously after _trainers is already updated above,
    // so it always filters the latest data.
    final filtered = _slotFilter == 'all'
        ? List<Map<String, dynamic>>.from(_trainers)
        : _trainers.where((t) {
            // BUG FIX 3: normalise both sides to lowercase + trim so
            // 'Midday', 'midday', ' midday ' all match 'midday'.
            final slot = (t['training_slot'] ?? '')
                .toString()
                .toLowerCase()
                .trim();
            return slot == _slotFilter.toLowerCase().trim();
          }).toList();

    // Only call setState if the widget is still mounted and we're not
    // already inside a setState (we call this from _loadTrainers which
    // calls its own setState after, so just update the field directly here).
    _filtered = filtered;
    print("AFTER FILTER: $_filtered");
  }

  void _showSlotFilter(BuildContext context) {
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
      items: _slotOptions.map((value) {
        final isSelected = value == _slotFilter;
        return PopupMenuItem<String>(
          value: value,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _slotLabel(value),
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
        // BUG FIX 3: setState here updates _slotFilter then calls _applyFilter
        // so the UI reflects the new filter immediately using already-loaded data
        // without triggering a network request.
        setState(() {
          _slotFilter = value;
          _applyFilter();
        });
      }
    });
  }

  Future<void> _deleteTrainer(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Delete Trainer',
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
      final result = await AdminService.deleteTrainer(id);
      if (result['success']) {
        Get.snackbar(
          'Deleted',
          '$name has been removed',
          backgroundColor: AppTheme.active,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        _loadTrainers();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to delete trainer',
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
    print("UI REBUILD");
    return AppShell(
      role: 'admin',
      subtitle: 'Admin Panel',
      bottomNav: const AdminBottomNav(activeIndex: -1),
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
                    onRefresh: _loadTrainers,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => _buildTrainerCard(_filtered[i]),
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
                'Manage\nTrainers',
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
                    MaterialPageRoute(builder: (_) => const TrainerFormPage()),
                  );
                  if (result == true) await _loadTrainers();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Trainer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (_) => _loadTrainers(),
            decoration: InputDecoration(
              hintText: 'Search by name, email or specialization...',
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
                  onTap: () => _showSlotFilter(ctx),
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
                          _slotLabel(_slotFilter),
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

  Widget _buildTrainerCard(Map<String, dynamic> trainer) {
    print(trainer);
    final name = trainer['name'] ?? '';
    final email = trainer['email'] ?? '';
    final phone = trainer['phone'] ?? '';
    final spec = trainer['specialization'] ?? '';
    final exp = trainer['experience'];
    final slot = (trainer['training_slot'] ?? '').toString();
    final gender = trainer['gender'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // BUG FIX 1 (status): tinyint from MySQL comes as int 1/0 in Dart.
    // We handle int, bool, and string forms so it works regardless of how
    // the HTTP client deserialises the JSON number.
    final rawActive = trainer['is_active'];
    print(trainer['is_active']);
    final isActive = rawActive == 1;

    final statusColor = isActive ? AppTheme.active : AppTheme.expired;
    final statusBg = isActive ? AppTheme.activeLight : AppTheme.expiredLight;
    print(isActive);
    final statusLabel = isActive ? 'Active' : 'Inactive';

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
                      if (spec.isNotEmpty)
                        Text(
                          spec,
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
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 10),

            // BUG FIX 2 (N/A fields): guard each field so empty string shows
            // 'N/A' but a non-empty value always shows — previously the null
            // coalescing returned '' which the card displayed as blank/N/A.
            _infoRow(Icons.email_outlined, email.isNotEmpty ? email : 'N/A'),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, phone.isNotEmpty ? phone : 'N/A'),
            if (gender.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.person_outline, _cap(gender)),
            ],
            if (slot.isNotEmpty) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.schedule_outlined, 'Slot: ${_cap(slot)}'),
            ],
            if (exp != null) ...[
              const SizedBox(height: 6),
              _infoRow(
                Icons.workspace_premium_outlined,
                // exp may arrive as String from JSON; parse safely
                '${exp.toString()} year${exp.toString() == '1' ? '' : 's'} experience',
              ),
            ],

            const SizedBox(height: 14),
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
                              TrainerFormPage(trainerId: trainer['id']),
                        ),
                      );
                      if (result == true) await _loadTrainers();
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
                    onPressed: () => _deleteTrainer(trainer['id'], name),
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

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            'No trainers found',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _slotFilter != 'all'
                ? 'Try changing the slot filter'
                : 'Add your first trainer',
            style: const TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}

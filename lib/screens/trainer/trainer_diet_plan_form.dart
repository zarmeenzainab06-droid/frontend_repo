import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/trainer_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/trainer_drawer.dart';

class TrainerDietPlanForm extends StatefulWidget {
  @override
  State<TrainerDietPlanForm> createState() => _TrainerDietPlanFormState();
}

class _TrainerDietPlanFormState extends State<TrainerDietPlanForm> {
  bool _isLoading = false;
  bool _isFetching = false;

  // Args
  Map<String, dynamic>? _memberArg;
  int? _planId;

  // Plan data
  Map<String, dynamic>? _existingPlan;

  // Members list for dropdown
  List<Map<String, dynamic>> _members = [];
  int? _selectedMemberId;
  String _selectedMemberName = '';

  // Form controllers
  final _titleCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _breakfastCtrl = TextEditingController();
  final _lunchCtrl = TextEditingController();
  final _dinnerCtrl = TextEditingController();
  final _snacksCtrl = TextEditingController();

  bool get _isEdit => _planId != null;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _memberArg = args?['member'] as Map<String, dynamic>?;
    _planId = args?['plan_id'];

    // Pre-fill date
    final now = DateTime.now();
    _dateCtrl.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isFetching = true);

    // Load members list
    final membersResult = await TrainerService.getMyMembers();
    if (membersResult['success']) {
      _members = List<Map<String, dynamic>>.from(membersResult['members']);
    }

    // If member passed as argument, pre-select
    if (_memberArg != null) {
      _selectedMemberId = _memberArg!['id'];
      _selectedMemberName = _memberArg!['name'] ?? '';
    }

    // If editing, load plan data
    if (_isEdit) {
      final planResult = await TrainerService.getDietPlan(_planId!);
      if (planResult['success']) {
        _existingPlan = planResult['plan'];
        _titleCtrl.text = _existingPlan!['title'] ?? '';
        _breakfastCtrl.text = _existingPlan!['breakfast'] ?? '';
        _lunchCtrl.text = _existingPlan!['lunch'] ?? '';
        _dinnerCtrl.text = _existingPlan!['dinner'] ?? '';
        _snacksCtrl.text = _existingPlan!['snacks'] ?? '';
        if (_existingPlan!['assignment_date'] != null) {
          _dateCtrl.text = _existingPlan!['assignment_date'].toString().split(
            'T',
          )[0];
        }
        _selectedMemberId = _existingPlan!['member_id'];
        _selectedMemberName = _existingPlan!['member_name'] ?? '';
      }
    }

    setState(() => _isFetching = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (_selectedMemberId == null) {
      Get.snackbar(
        'Error',
        'Please select a member',
        backgroundColor: AppTheme.expired,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a diet plan title',
        backgroundColor: AppTheme.expired,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_dateCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please select an assignment date',
        backgroundColor: AppTheme.expired,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> result;
    if (_isEdit) {
      result = await TrainerService.updateDietPlan(
        planId: _planId!,
        memberId: _selectedMemberId!,
        title: _titleCtrl.text.trim(),
        assignmentDate: _dateCtrl.text.trim(),
        breakfast: _breakfastCtrl.text.trim(),
        lunch: _lunchCtrl.text.trim(),
        dinner: _dinnerCtrl.text.trim(),
        snacks: _snacksCtrl.text.trim(),
      );
    } else {
      result = await TrainerService.createDietPlan(
        memberId: _selectedMemberId!,
        title: _titleCtrl.text.trim(),
        assignmentDate: _dateCtrl.text.trim(),
        breakfast: _breakfastCtrl.text.trim(),
        lunch: _lunchCtrl.text.trim(),
        dinner: _dinnerCtrl.text.trim(),
        snacks: _snacksCtrl.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (result['success']) {
      Get.snackbar(
        'Success',
        _isEdit ? 'Diet plan updated!' : 'Diet plan created!',
        backgroundColor: AppTheme.active,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      // ✅ Go directly to diet plans page so new plan is visible immediately
      Get.offAllNamed('/trainer/diet-plans');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const TrainerDrawer(),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isFetching
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Page title ───────────────────────
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSm,
                                  ),
                                  boxShadow: [AppTheme.cardShadow],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEdit
                                      ? 'Edit Diet Plan'
                                      : 'Create Diet Plan',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (_selectedMemberName.isNotEmpty)
                                  Text(
                                    'For: $_selectedMemberName',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Plan Information Card ─────────────
                        _sectionCard(
                          icon: Icons.restaurant_menu_outlined,
                          iconColor: AppTheme.primary,
                          title: 'Plan Information',
                          children: [
                            // Member Dropdown
                            _fieldLabel('Select Member *'),
                            _buildMemberDropdown(),
                            const SizedBox(height: 14),

                            // Diet Plan Title
                            _fieldLabel('Diet Plan Title *'),
                            _buildTextField(
                              _titleCtrl,
                              'e.g. High Protein Muscle Gain',
                            ),
                            const SizedBox(height: 14),

                            // Assignment Date
                            _fieldLabel('Assignment Date *'),
                            _buildDateField(),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Meal Plan Card ────────────────────
                        _sectionCard(
                          icon: Icons.fastfood_outlined,
                          iconColor: Colors.orange,
                          title: 'Meal Plan',
                          children: [
                            _mealSection(
                              icon: Icons.wb_sunny_outlined,
                              iconColor: Colors.orange,
                              bgColor: const Color(0xFFFFF8E1),
                              label: 'Breakfast',
                              ctrl: _breakfastCtrl,
                              hint:
                                  'e.g. Oatmeal with banana and honey\n4 boiled eggs\n1 glass whole milk',
                            ),
                            const SizedBox(height: 14),
                            _mealSection(
                              icon: Icons.wb_cloudy_outlined,
                              iconColor: Colors.deepOrange,
                              bgColor: const Color(0xFFFFF3E0),
                              label: 'Lunch',
                              ctrl: _lunchCtrl,
                              hint:
                                  'e.g. Grilled chicken breast (200g)\nBrown rice (1 cup)\nSteamed vegetables',
                            ),
                            const SizedBox(height: 14),
                            _mealSection(
                              icon: Icons.nightlight_outlined,
                              iconColor: Colors.indigo,
                              bgColor: const Color(0xFFEDE7F6),
                              label: 'Dinner',
                              ctrl: _dinnerCtrl,
                              hint:
                                  'e.g. Baked salmon (150g)\nSweet potato\nMixed green salad',
                            ),
                            const SizedBox(height: 14),
                            _mealSection(
                              icon: Icons.eco_outlined,
                              iconColor: Colors.green,
                              bgColor: const Color(0xFFE8F5E9),
                              label: 'Snacks / Supplements',
                              ctrl: _snacksCtrl,
                              hint: 'e.g. Protein shake\nFruits\nNuts',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Save + Cancel Buttons ─────────────
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _save,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _isEdit
                                            ? Icons.save_outlined
                                            : Icons.add,
                                        size: 18,
                                      ),
                                label: Text(
                                  _isEdit
                                      ? 'Update Diet Plan'
                                      : 'Create Diet Plan',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textPrimary,
                                side: const BorderSide(color: AppTheme.border),
                                minimumSize: const Size(100, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
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

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMemberDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMemberId,
          isExpanded: true,
          hint: const Text(
            'Select a member',
            style: TextStyle(color: AppTheme.textHint, fontSize: 14),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textSecondary,
          ),
          items: _members.map((m) {
            final pkg = m['plan'] ?? '';
            final dur = m['plan_duration'];
            final pkgLabel = pkg.isNotEmpty
                ? (dur != null ? ' — $pkg ${dur}d' : ' — $pkg')
                : '';
            return DropdownMenuItem<int>(
              value: m['id'],
              child: Text(
                '${m['name']}$pkgLabel',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              final member = _members.firstWhere(
                (m) => m['id'] == val,
                orElse: () => {},
              );
              setState(() {
                _selectedMemberId = val;
                _selectedMemberName = member['name'] ?? '';
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        filled: true,
        fillColor: AppTheme.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
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
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              _dateCtrl.text.isNotEmpty ? _dateCtrl.text : 'Select date',
              style: TextStyle(
                fontSize: 14,
                color: _dateCtrl.text.isNotEmpty
                    ? AppTheme.textPrimary
                    : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealSection({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required TextEditingController ctrl,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: BorderSide(color: iconColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
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
                onTap: () => Get.offNamed('/trainer/diet-plans'),
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

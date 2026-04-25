import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';

class EditMemberPage extends StatefulWidget {
  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Map<String, dynamic> _member;

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _feeCtrl;

  String? _gender;
  String? _packageId;
  String? _trainingSlot;
  String? _trainerId;

  List<Map<String, dynamic>> _trainers = [];
  List<Map<String, dynamic>> _packages = [];

  final List<Map<String, String>> _genders = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _slots = [
    {'value': 'morning', 'label': 'Morning (6:00 AM - 9:00 AM)'},
    {'value': 'midday', 'label': 'Mid-Day (10:00 AM - 2:00 PM)'},
    {'value': 'evening', 'label': 'Evening (4:00 PM - 8:00 PM)'},
    {'value': 'night', 'label': 'Night (8:00 PM - 10:00 PM)'},
  ];

  @override
  void initState() {
    super.initState();
    _member = Get.arguments as Map<String, dynamic>;

    _nameCtrl = TextEditingController(text: _member['name'] ?? '');
    _emailCtrl = TextEditingController(text: _member['email'] ?? '');
    _phoneCtrl = TextEditingController(text: _member['phone'] ?? '');
    _feeCtrl = TextEditingController(
      text: (_member['membership_fee'] ?? '99.00').toString(),
    );

    // Pre-fill gender
    final g = (_member['gender'] ?? '').toString().toLowerCase();
    if (['male', 'female', 'other'].contains(g)) _gender = g;

    // Pre-fill training slot
    final s = (_member['training_slot'] ?? '').toString().toLowerCase();
    if (['morning', 'midday', 'evening', 'night'].contains(s))
      _trainingSlot = s;

    _loadTrainers();
    _loadPackages();
  }

  Future<void> _loadTrainers() async {
    final result = await AdminService.getTrainers();
    if (result['success']) {
      setState(() {
        _trainers = List<Map<String, dynamic>>.from(result['trainers']);
        final tid = _member['trainer_id'];
        if (tid != null) _trainerId = tid.toString();
      });
    }
  }

  Future<void> _loadPackages() async {
    final result = await AdminService.getPackages(activeOnly: false);
    if (result['success']) {
      setState(() {
        _packages = List<Map<String, dynamic>>.from(result['packages']);
        // Pre-fill package — use package_id from member data
        final pid = _member['package_id'];
        if (pid != null) _packageId = pid.toString();
      });
    }
  }

  double _packagePrice(String? packageId) {
    if (packageId == null) return 99.00;
    final pkg = _packages.firstWhere(
      (p) => p['id'].toString() == packageId,
      orElse: () => <String, dynamic>{},
    );
    return double.tryParse(pkg['price']?.toString() ?? '99') ?? 99.00;
  }

  String _calcEndDate(String packageId) {
    final pkg = _packages.firstWhere(
      (p) => p['id'].toString() == packageId,
      orElse: () => <String, dynamic>{'duration': 30},
    );
    final days = (pkg['duration'] ?? 30) as int;
    final end = DateTime.now().add(Duration(days: days));
    return '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Update user details
    final updateResult = await AdminService.updateMember(
      userId: _member['id'],
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender ?? 'male',
      trainingSlot: _trainingSlot ?? 'morning',
      trainerId: _trainerId,
    );

    if (!updateResult['success']) {
      setState(() => _isLoading = false);
      _showError(updateResult['message'] ?? 'Failed to update member');
      return;
    }

    // If package changed, reassign membership
    final originalPackageId = _member['package_id']?.toString();
    if (_packageId != null && _packageId != originalPackageId) {
      final now = DateTime.now();
      final startDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final endDate = _calcEndDate(_packageId!);

      await AdminService.assignMembership(
        userId: _member['id'],
        packageId: int.parse(_packageId!),
        startDate: startDate,
        endDate: endDate,
        amount: double.tryParse(_feeCtrl.text) ?? _packagePrice(_packageId),
        paymentMethod: 'cash',
      );
    }

    setState(() => _isLoading = false);

    Get.snackbar(
      'Updated',
      'Member updated successfully!',
      backgroundColor: AppTheme.active,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
    Get.back(result: true);
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: AppTheme.expired,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Full Name *'),
                    _textField(
                      controller: _nameCtrl,
                      hint: 'Enter full name',
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _label('Email Address *'),
                    _textField(
                      controller: _emailCtrl,
                      hint: 'member@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Phone Number *'),
                    _textField(
                      controller: _phoneCtrl,
                      hint: '+1 234 567 8900',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _label('Gender'),
                    _dropdownField(
                      hint: 'Select gender',
                      value: _gender,
                      items: _genders,
                      onChanged: (val) => setState(() => _gender = val),
                    ),
                    const SizedBox(height: 16),

                    _label('Membership Plan'),
                    _dropdownField(
                      hint: _packages.isEmpty
                          ? 'Loading plans...'
                          : 'Select plan',
                      value: _packageId,
                      items: _packages
                          .map(
                            (p) => {
                              'value': p['id'].toString(),
                              'label':
                                  '${p['name']} - ${p['duration']} days (\$${p['price']})',
                            },
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _packageId = val;
                          _feeCtrl.text = _packagePrice(val).toStringAsFixed(2);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Assign Trainer'),
                    _dropdownField(
                      hint: _trainers.isEmpty
                          ? 'No trainers available'
                          : 'Select trainer',
                      value: _trainerId,
                      items: _trainers
                          .map(
                            (t) => {
                              'value': t['id'].toString(),
                              'label': t['name'].toString(),
                            },
                          )
                          .toList(),
                      onChanged: _trainers.isEmpty
                          ? null
                          : (val) => setState(() => _trainerId = val),
                    ),
                    const SizedBox(height: 16),

                    _label('Training Slot'),
                    _dropdownField(
                      hint: 'Select time slot',
                      value: _trainingSlot,
                      items: _slots,
                      onChanged: (val) => setState(() => _trainingSlot = val),
                    ),
                    const SizedBox(height: 16),

                    _label('Membership Fee (\$)'),
                    _textField(
                      controller: _feeCtrl,
                      hint: '99.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => v!.isEmpty ? 'Fee is required' : null,
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined, size: 18),
                            label: Text(
                              _isLoading ? 'Updating...' : 'Update Member',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            side: const BorderSide(color: AppTheme.border),
                            minimumSize: const Size(90, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 16,
        bottom: 12,
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
          const Text(
            'Edit Member',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
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

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: AppTheme.textHint, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            fontFamily: 'Poppins',
          ),
          dropdownColor: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

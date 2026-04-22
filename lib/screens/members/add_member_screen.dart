import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';

class AddMemberPage extends StatefulWidget {
  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '99.00');

  // Dropdown values
  String? _gender;
  String? _plan;
  String? _trainingSlot;
  String? _trainerId;

  // Trainers list loaded from backend
  List<Map<String, dynamic>> _trainers = [];

  final List<Map<String, String>> _genders = [
    {'value': 'male', 'label': 'Male'},
    {'value': 'female', 'label': 'Female'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _plans = [
    {'value': 'basic', 'label': 'Basic - 1 Month'},
    {'value': 'standard', 'label': 'Standard - 3 Months'},
    {'value': 'premium', 'label': 'Premium - 6 Months'},
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
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    final result = await AdminService.getTrainers();
    if (result['success']) {
      setState(() {
        _trainers = List<Map<String, dynamic>>.from(result['trainers']);
      });
    }
  }

  double _planFee(String? plan) {
    switch (plan) {
      case 'basic':
        return 99.00;
      case 'standard':
        return 249.00;
      case 'premium':
        return 449.00;
      default:
        return 99.00;
    }
  }

  String _calcEndDate(String plan) {
    final now = DateTime.now();
    late DateTime end;
    switch (plan) {
      case 'basic':
        end = DateTime(now.year, now.month + 1, now.day);
        break;
      case 'standard':
        end = DateTime(now.year, now.month + 3, now.day);
        break;
      case 'premium':
        end = DateTime(now.year, now.month + 6, now.day);
        break;
      default:
        end = DateTime(now.year, now.month + 1, now.day);
    }
    return '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      _showError('Please select a gender');
      return;
    }
    if (_plan == null) {
      _showError('Please select a membership plan');
      return;
    }
    if (_trainingSlot == null) {
      _showError('Please select a training slot');
      return;
    }

    setState(() => _isLoading = true);

    // 1. Create the user account
    final signupResult = await AdminService.createMember(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender!,
      trainingSlot: _trainingSlot!,
      trainerId: _trainerId,
    );

    if (!signupResult['success']) {
      setState(() => _isLoading = false);
      _showError(signupResult['message'] ?? 'Failed to create member');
      return;
    }

    final int userId = signupResult['user_id'];
    final now = DateTime.now();
    final startDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final endDate = _calcEndDate(_plan!);

    // 2. Assign membership
    final membershipResult = await AdminService.assignMembership(
      userId: userId,
      plan: _plan!,
      startDate: startDate,
      endDate: endDate,
      amount: double.tryParse(_feeCtrl.text) ?? _planFee(_plan),
      paymentMethod: 'cash',
    );

    setState(() => _isLoading = false);

    if (membershipResult['success']) {
      Get.snackbar(
        'Success',
        'Member added successfully!',
        backgroundColor: AppTheme.active,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      Get.back(result: true);
    } else {
      _showError(membershipResult['message'] ?? 'Failed to assign membership');
    }
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

                    _label('Gender *'),
                    _dropdownField(
                      hint: 'Select gender',
                      value: _gender,
                      items: _genders,
                      onChanged: (val) => setState(() => _gender = val),
                    ),
                    const SizedBox(height: 16),

                    _label('Membership Plan *'),
                    _dropdownField(
                      hint: 'Select plan',
                      value: _plan,
                      items: _plans,
                      onChanged: (val) {
                        setState(() {
                          _plan = val;
                          _feeCtrl.text = _planFee(val).toStringAsFixed(2);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Assign Trainer'),
                    _dropdownField(
                      hint: 'Select trainer',
                      value: _trainerId,
                      items: _trainers
                          .map(
                            (t) => {
                              'value': t['id'].toString(),
                              'label': t['name'].toString(),
                            },
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _trainerId = val),
                    ),
                    const SizedBox(height: 16),

                    _label('Training Slot *'),
                    _dropdownField(
                      hint: 'Select time slot',
                      value: _trainingSlot,
                      items: _slots,
                      onChanged: (val) => setState(() => _trainingSlot = val),
                    ),
                    const SizedBox(height: 16),

                    _label('Membership Fee (\$) *'),
                    _textField(
                      controller: _feeCtrl,
                      hint: '99.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => v!.isEmpty ? 'Fee is required' : null,
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
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
                              _isLoading ? 'Saving...' : 'Save Member',
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

  // ── Top Bar ──────────────────────────────────────────────────
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
            'Add New Member',
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

  // ── Helpers ───────────────────────────────────────────────────
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
    required ValueChanged<String?> onChanged,
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

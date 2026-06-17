import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';

class MemberFormPage extends StatefulWidget {
  final int? memberId; // null = ADD, not null = EDIT

  const MemberFormPage({super.key, this.memberId});

  @override
  State<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends State<MemberFormPage> {
  bool get _isEdit => widget.memberId != null;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetching = false;

  final _passwordCtrl = TextEditingController(); // for password
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '99.00');
  final _startDateCtrl = TextEditingController();

  String? _gender;
  String? _packageId;
  String? _trainingSlot;
  String? _trainerId;
  String _paymentType = 'cash';

  // New screenshot picked by user
  Uint8List? _screenshotBytes;
  String? _screenshotName;

  // Existing screenshot path from server (edit mode) — NEVER cleared unless user picks new
  String? _existingScreenshotPath;

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
    final now = DateTime.now();
    _startDateCtrl.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    _loadDropdowns().then((_) {
      if (_isEdit) _fetchMemberData();
    });
  }

  // DISPOSE
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _feeCtrl.dispose();
    _startDateCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose(); // always last
  }

  Future<void> _loadDropdowns() async {
    final results = await Future.wait([
      AdminService.getTrainers(),
      AdminService.getPackages(activeOnly: false),
    ]);
    if (!mounted) return; // ← ADD THIS
    if (results[0]['success']) {
      setState(() {
        _trainers = List<Map<String, dynamic>>.from(results[0]['trainers']);
      });
    }
    if (results[1]['success']) {
      setState(() {
        _packages = List<Map<String, dynamic>>.from(results[1]['packages']);
      });
    }
  }

  Future<void> _fetchMemberData() async {
    setState(() => _isFetching = true);
    final result = await AdminService.getMemberById(widget.memberId!);
    if (!mounted) return; // ← ADD THIS

    if (!result['success']) {
      setState(() => _isFetching = false);
      _showError(result['message'] ?? 'Failed to load member data');
      return;
    }
    final data = result['member'];
    setState(() {
      _nameCtrl.text = data['name'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _feeCtrl.text = (data['membership_fee'] ?? '99.00').toString();

      final g = (data['gender'] ?? '').toString().toLowerCase();
      if (['male', 'female', 'other'].contains(g)) _gender = g;

      final s = (data['training_slot'] ?? '').toString().toLowerCase();
      if (['morning', 'midday', 'evening', 'night'].contains(s)) {
        _trainingSlot = s;
      }

      final tid = data['trainer_id'];
      if (tid != null) _trainerId = tid.toString();

      final pid = data['package_id'];
      if (pid != null) _packageId = pid.toString();

      // ✅ FIX: Set payment type from DB — this drives whether screenshot section shows
      final pm = (data['payment_method'] ?? 'cash').toString().toLowerCase();
      _paymentType = ['cash', 'online'].contains(pm) ? pm : 'cash';

      // ✅ FIX: Always load existing screenshot — NEVER cleared when switching to cash/online
      // It is only replaced when user explicitly picks a new image
      _existingScreenshotPath = data['payment_screenshot'];

      _isFetching = false;
    });
  }

  double _packagePrice(String? packageId) {
    if (packageId == null) return 99.00;
    final pkg = _packages.firstWhere(
      (p) => p['id'].toString() == packageId,
      orElse: () => <String, dynamic>{},
    );
    return double.tryParse(pkg['price']?.toString() ?? '99') ?? 99.00;
  }

  String _calcEndDate(String startDate, String packageId) {
    final pkg = _packages.firstWhere(
      (p) => p['id'].toString() == packageId,
      orElse: () => <String, dynamic>{'duration': 30},
    );
    final days = (pkg['duration'] ?? 30) as int;
    final start = DateTime.parse(startDate);
    final end = start.add(Duration(days: days));
    return '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _screenshotBytes = bytes;
        _screenshotName = picked.name;
        // ✅ FIX: Clear old path only when user picks a NEW image (replacing it)
        _existingScreenshotPath = null;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      setState(() {
        _startDateCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      _showError('Please select a gender');
      return;
    }
    if (_packageId == null) {
      _showError('Please select a membership plan');
      return;
    }
    if (_trainingSlot == null) {
      _showError('Please select a training slot');
      return;
    }

    // ✅ FIX: Screenshot required only on ADD with online payment
    // On EDIT: existing path counts as having a screenshot
    if (_paymentType == 'online' && !_isEdit && _screenshotBytes == null) {
      _showError('Please upload a payment screenshot');
      return;
    }

    setState(() => _isLoading = true);
    if (_isEdit) {
      await _submitEdit();
    } else {
      await _submitAdd();
    }
  }

  Future<void> _submitAdd() async {
    final signupResult = await AdminService.createMember(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender!,
      trainingSlot: _trainingSlot!,
      trainerId: _trainerId,
      password: _passwordCtrl.text.trim(),
    );

    if (!signupResult['success']) {
      if (!mounted) return; // ← ADD THIS
      setState(() => _isLoading = false);
      _showError(signupResult['message'] ?? 'Failed to create member');
      return;
    }

    final int userId = signupResult['user_id'];
    final startDate = _startDateCtrl.text;
    final endDate = _calcEndDate(startDate, _packageId!);

    final membershipResult = await AdminService.assignMembership(
      userId: userId,
      packageId: int.parse(_packageId!),
      startDate: startDate,
      endDate: endDate,
      amount: double.tryParse(_feeCtrl.text) ?? _packagePrice(_packageId),
      paymentMethod: _paymentType,
      screenshotBytes: _screenshotBytes,
      screenshotName: _screenshotName,
    );

    // fix dup
    // final membershipResult = await AdminService.updateMembership(
    //   userId: widget.memberId!,
    //   packageId: int.parse(_packageId!),
    //   startDate: startDate,
    //   endDate: endDate,
    //   amount: double.tryParse(_feeCtrl.text) ?? _packagePrice(_packageId),
    //   paymentMethod: _paymentType,
    //   screenshotBytes: _screenshotBytes,
    //   screenshotName: _screenshotName,
    //   existingScreenshotPath: _existingScreenshotPath,
    // );

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

      // get.back chnage for added member

      Navigator.pop(context, true);
    } else {
      _showError(membershipResult['message'] ?? 'Failed to assign membership');
    }
  }

  Future<void> _submitEdit() async {
    final updateResult = await AdminService.updateMember(
      userId: widget.memberId!,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender ?? 'male',
      trainingSlot: _trainingSlot ?? 'morning',
      trainerId: _trainerId,
    );
    if (!mounted) return; // ← ADD THIS
    if (!updateResult['success']) {
      setState(() => _isLoading = false);
      _showError(updateResult['message'] ?? 'Failed to update member');
      return;
    }

    final startDate = _startDateCtrl.text;
    final endDate = _calcEndDate(startDate, _packageId!);

    // ✅ FIX: Pass existingScreenshotPath so backend can keep old screenshot
    // when user didn't pick a new one
    // print(_existingScreenshotPath);
    // await AdminService.assignMembership(
    //   userId: widget.memberId!,
    //   packageId: int.parse(_packageId!),
    //   startDate: startDate,
    //   endDate: endDate,
    //   amount: double.tryParse(_feeCtrl.text) ?? _packagePrice(_packageId),
    //   paymentMethod: _paymentType,
    //   screenshotBytes: _screenshotBytes, // null if not changed
    //   screenshotName: _screenshotName, // null if not changed
    //   existingScreenshotPath: _existingScreenshotPath, // ✅ NEW: keep old path
    // );

    // setState(() => _isLoading = false);
    // Get.snackbar(
    //   'Updated',
    //   'Member updated successfully!',
    //   backgroundColor: AppTheme.active,
    //   colorText: Colors.white,
    //   snackPosition: SnackPosition.BOTTOM,
    //   margin: const EdgeInsets.all(16),
    // );
    // Navigator.pop(context, true); //Get.back(result: true); edit member
    final membershipResult = await AdminService.updateMembership(
      userId: widget.memberId!,
      packageId: int.parse(_packageId!),
      startDate: startDate,
      endDate: endDate,
      amount: double.tryParse(_feeCtrl.text) ?? _packagePrice(_packageId),
      paymentMethod: _paymentType,
      screenshotBytes: _screenshotBytes,
      screenshotName: _screenshotName,
      existingScreenshotPath: _existingScreenshotPath,
    );

    setState(() => _isLoading = false);

    if (membershipResult['success'] == true) {
      Get.snackbar(
        'Updated',
        'Member updated successfully!',
        backgroundColor: AppTheme.active,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      Navigator.pop(context, true);
    } else {
      _showError(membershipResult['message'] ?? 'Failed to update membership');
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
            child: _isFetching
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : SingleChildScrollView(
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
                            validator: (v) =>
                                v!.isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 16),

                          _label('Email Address *'),
                          _textField(
                            controller: _emailCtrl,
                            hint: 'member@example.com',
                            keyboardType: TextInputType.emailAddress,
                            readOnly: _isEdit,
                            validator: (v) {
                              if (v!.isEmpty) return 'Email is required';
                              if (!v.contains('@'))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _label('Phone Number *'),
                          _textField(
                            controller: _phoneCtrl,
                            hint: '+1 234 567 8900',
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v!.isEmpty ? 'Phone is required' : null,
                          ),
                          const SizedBox(height: 16),
                          // for password
                          const SizedBox(height: 16),
                          if (!_isEdit) ...[
                            _label('Password *'),
                            _textField(
                              controller: _passwordCtrl,
                              hint: 'Assign a password',
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Password is required';
                                if (v.trim().length < 6)
                                  return 'Minimum 6 characters';
                                return null;
                              },
                            ),
                          ],
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
                                _feeCtrl.text = _packagePrice(
                                  val,
                                ).toStringAsFixed(2);
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

                          _label('Training Slot *'),
                          _dropdownField(
                            hint: 'Select time slot',
                            value: _trainingSlot,
                            items: _slots,
                            onChanged: (val) =>
                                setState(() => _trainingSlot = val),
                          ),
                          const SizedBox(height: 16),

                          _label('Membership Start Date *'),
                          GestureDetector(
                            onTap: _pickStartDate,
                            child: AbsorbPointer(
                              child: _textField(
                                controller: _startDateCtrl,
                                hint: 'YYYY-MM-DD',
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                validator: (v) => v!.isEmpty
                                    ? 'Start date is required'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _label('Payment Type *'),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  // ✅ FIX: Switching to Cash no longer clears _existingScreenshotPath
                                  onTap: () => setState(() {
                                    _paymentType = 'cash';
                                    _screenshotBytes = null;
                                    _screenshotName = null;
                                    // Do NOT clear _existingScreenshotPath here
                                  }),
                                  child: _paymentBtn(
                                    label: 'Cash',
                                    icon: Icons.payments_outlined,
                                    isSelected: _paymentType == 'cash',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _paymentType = 'online'),
                                  child: _paymentBtn(
                                    label: 'Online',
                                    icon: Icons.phone_android_outlined,
                                    isSelected: _paymentType == 'online',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_paymentType == 'online') ...[
                            _label(
                              'Payment Screenshot${_isEdit ? ' (optional — keep old if not changed)' : ' *'}',
                            ),
                            GestureDetector(
                              onTap: _pickScreenshot,
                              child: Container(
                                width: double.infinity,
                                height:
                                    (_screenshotBytes != null ||
                                        _existingScreenshotPath != null)
                                    ? 180
                                    : 110,
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                  border: Border.all(
                                    color:
                                        (_screenshotBytes != null ||
                                            _existingScreenshotPath != null)
                                        ? AppTheme.active
                                        : AppTheme.border,
                                  ),
                                ),
                                child: _buildScreenshotPreview(),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          _label('Amount Paid (PKR) *'),
                          _textField(
                            controller: _feeCtrl,
                            hint: '0.00',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Amount is required' : null,
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
                                      : const Icon(
                                          Icons.save_outlined,
                                          size: 18,
                                        ),
                                  label: Text(
                                    _isLoading
                                        ? (_isEdit
                                              ? 'Updating...'
                                              : 'Saving...')
                                        : (_isEdit
                                              ? 'Update Member'
                                              : 'Save Member'),
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
                                  side: const BorderSide(
                                    color: AppTheme.border,
                                  ),
                                  minimumSize: const Size(90, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                  ),
                                ),

                                //onPressed: () => Get.back()has chnge,
                                onPressed: () => Navigator.pop(context),

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

  Widget _buildScreenshotPreview() {
    if (_screenshotBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_screenshotBytes!, fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickScreenshot,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_existingScreenshotPath != null) {
      final url =
          '${AdminService.baseUrl}/${_existingScreenshotPath!.replaceAll('\\', '/')}';
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: AppTheme.textHint,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickScreenshot,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.upload_outlined, size: 32, color: AppTheme.textHint),
        const SizedBox(height: 8),
        Text(
          _isEdit ? 'Tap to upload new screenshot' : 'Tap to upload screenshot',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const Text(
          'JPG, PNG supported',
          style: TextStyle(fontSize: 11, color: AppTheme.textHint),
        ),
      ],
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
          Text(
            _isEdit ? 'Edit Member' : 'Add New Member',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBtn({
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
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
    Widget? suffixIcon,
    bool readOnly = false,
    bool obscureText = false, // for password

    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      obscureText: obscureText, // for password

      style: TextStyle(
        fontSize: 14,
        color: readOnly ? AppTheme.textSecondary : AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: readOnly
            ? AppTheme.border.withOpacity(0.3)
            : AppTheme.background,
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
          borderSide: BorderSide(
            color: readOnly ? AppTheme.border : AppTheme.primary,
            width: 1.5,
          ),
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

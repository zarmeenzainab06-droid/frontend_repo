import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/admin_slot_service.dart';
import '../../core/utils/theme.dart';

class SlotFormPage extends StatefulWidget {
  final int? slotId;
  const SlotFormPage({super.key, this.slotId});

  @override
  State<SlotFormPage> createState() => _SlotFormPageState();
}

class _SlotFormPageState extends State<SlotFormPage> {
  bool get _isEdit => widget.slotId != null;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetching = false;

  final _nameCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String _status = 'active';
  bool _timeError = false; // end time before start time

  // Schedule days
  final List<String> _allDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final Set<String> _selectedDays = {
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  };
  bool _daysError = false;

  // Store raw TimeOfDay for comparison
  TimeOfDay? _startTOD;
  TimeOfDay? _endTOD;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _fetchSlot();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSlot() async {
    setState(() => _isFetching = true);
    final result = await AdminService.getSlotById(widget.slotId!);
    if (!mounted) return;
    if (result['success']) {
      final slot = result['slot'];
      setState(() {
        _nameCtrl.text = slot['name'] ?? '';
        _startTimeCtrl.text = slot['start_time'] ?? '';
        _endTimeCtrl.text = slot['end_time'] ?? '';
        _capacityCtrl.text = slot['capacity'].toString();
        _status = (slot['status'] ?? 'active').toString().toLowerCase();

        // Load schedule days if saved
        final days = slot['schedule_days'];
        if (days != null && days.toString().isNotEmpty) {
          _selectedDays.clear();
          _selectedDays.addAll(days.toString().split(','));
        }
      });
    }
    setState(() => _isFetching = false);
  }

  String _formatTOD(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTOD ?? const TimeOfDay(hour: 6, minute: 0))
        : (_endTOD ?? const TimeOfDay(hour: 8, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startTOD = picked;
        _startTimeCtrl.text = _formatTOD(picked);
      } else {
        _endTOD = picked;
        _endTimeCtrl.text = _formatTOD(picked);
      }
      // Validate end > start
      _timeError =
          _startTOD != null &&
          _endTOD != null &&
          (_endTOD!.hour < _startTOD!.hour ||
              (_endTOD!.hour == _startTOD!.hour &&
                  _endTOD!.minute <= _startTOD!.minute));
    });
  }

  Future<void> _submit() async {
    // Validate days
    setState(() => _daysError = _selectedDays.isEmpty);
    if (_selectedDays.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;
    if (_timeError) return;

    setState(() => _isLoading = true);

    final cap = int.tryParse(_capacityCtrl.text.trim()) ?? 30;
    final scheduleDays = _selectedDays.join(',');

    Map<String, dynamic> result;
    if (_isEdit) {
      result = await AdminService.updateSlot(
        id: widget.slotId!,
        name: _nameCtrl.text.trim(),
        startTime: _startTimeCtrl.text.trim(),
        endTime: _endTimeCtrl.text.trim(),
        capacity: cap,
        status: _status,
        scheduleDays: scheduleDays,
      );
    } else {
      result = await AdminService.createSlot(
        name: _nameCtrl.text.trim(),
        startTime: _startTimeCtrl.text.trim(),
        endTime: _endTimeCtrl.text.trim(),
        capacity: cap,
        status: _status,
        scheduleDays: scheduleDays,
      );
    }

    setState(() => _isLoading = false);
    if (result['success']) {
      Get.snackbar(
        _isEdit ? 'Updated' : 'Created',
        _isEdit ? 'Slot updated successfully!' : 'Slot added successfully!',
        backgroundColor: AppTheme.active,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      Navigator.pop(context, true);
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
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Slot Information Section ──────────────────
                          _sectionCard(
                            title: 'Slot Information',
                            children: [
                              _label('Slot Name *'),
                              _textField(
                                controller: _nameCtrl,
                                hint: 'e.g. Morning Cardio, HIIT Training',
                                validator: (v) =>
                                    v!.isEmpty ? 'Slot name is required' : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Schedule Section ──────────────────────────
                          _sectionCard(
                            title: 'Schedule',
                            children: [
                              _label('Start Time *'),
                              _timeField(
                                controller: _startTimeCtrl,
                                hint: '07:01 PM',
                                onTap: () => _pickTime(isStart: true),
                                validator: (v) => v!.isEmpty
                                    ? 'Start time is required'
                                    : null,
                              ),
                              const SizedBox(height: 12),

                              _label('End Time *'),
                              _timeField(
                                controller: _endTimeCtrl,
                                hint: '07:01 PM',
                                onTap: () => _pickTime(isStart: false),
                                validator: (v) =>
                                    v!.isEmpty ? 'End time is required' : null,
                              ),

                              // ── Time error banner ──
                              if (_timeError) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.expiredLight,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppTheme.expired,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'End time must be after start time',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.expired,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),

                              // ── Schedule Days ──
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Schedule Days *',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedDays.length ==
                                            _allDays.length) {
                                          _selectedDays.clear();
                                        } else {
                                          _selectedDays.addAll(_allDays);
                                        }
                                        _daysError = _selectedDays.isEmpty;
                                      });
                                    },
                                    child: Text(
                                      _selectedDays.length == _allDays.length
                                          ? 'Deselect All'
                                          : 'Select All',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _allDays.map((day) {
                                  final isSelected = _selectedDays.contains(
                                    day,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedDays.remove(day);
                                        } else {
                                          _selectedDays.add(day);
                                        }
                                        _daysError = _selectedDays.isEmpty;
                                      });
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : AppTheme.background,
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSm,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : AppTheme.border,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          day,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (_daysError) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Please select at least one day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.expired,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Capacity & Status Section ─────────────────
                          _sectionCard(
                            title: 'Capacity & Status',
                            children: [
                              _label('Maximum Capacity *'),
                              _textField(
                                controller: _capacityCtrl,
                                hint: 'e.g. 20',
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(
                                  Icons.people_outline,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                helperText:
                                    'Maximum number of members per session',
                                validator: (v) {
                                  if (v!.isEmpty) return 'Capacity is required';
                                  if (int.tryParse(v) == null ||
                                      int.parse(v) < 1)
                                    return 'Enter a valid number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              _label('Status *'),
                              _statusDropdown(),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Submit Buttons ────────────────────────────
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
                                              ? 'Update Slot'
                                              : 'Save Slot'),
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

  // ── Section card wrapper ────────────────────────────────────
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ── Time field with clock icon ──────────────────────────────
  Widget _timeField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
            prefixIcon: const Icon(
              Icons.access_time_outlined,
              size: 18,
              color: AppTheme.textSecondary,
            ),
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
        ),
      ),
    );
  }

  // ── Status dropdown ─────────────────────────────────────────
  Widget _statusDropdown() {
    final isActive = _status == 'active';
    return GestureDetector(
      onTap: () async {
        final picked = await showMenu<String>(
          context: context,
          color: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          position: RelativeRect.fromLTRB(
            16,
            MediaQuery.of(context).size.height * 0.72,
            16,
            0,
          ),
          items: [
            PopupMenuItem(
              value: 'active',
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 10, color: AppTheme.active),
                  SizedBox(width: 10),
                  Text(
                    'Active',
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'inactive',
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 10, color: AppTheme.textSecondary),
                  SizedBox(width: 10),
                  Text(
                    'Inactive',
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        );
        if (picked != null) setState(() => _status = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: isActive ? AppTheme.active : AppTheme.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
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
    Widget? prefixIcon,
    String? helperText,
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
        prefixIcon: prefixIcon,
        helperText: helperText,
        helperStyle: const TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit ? 'Edit Time Slot' : 'Add Time Slot',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Configure a new gym session slot',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

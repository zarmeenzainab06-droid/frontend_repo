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
  final _capacityCtrl = TextEditingController(text: '30');
  String _status = 'active';

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
      });
    }
    setState(() => _isFetching = false);
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      ctrl.text = '${hour.toString().padLeft(2, '0')}:$minute $period';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final cap = int.tryParse(_capacityCtrl.text.trim()) ?? 30;

    Map<String, dynamic> result;
    if (_isEdit) {
      result = await AdminService.updateSlot(
        id: widget.slotId!,
        name: _nameCtrl.text.trim(),
        startTime: _startTimeCtrl.text.trim(),
        endTime: _endTimeCtrl.text.trim(),
        capacity: cap,
        status: _status,
      );
    } else {
      result = await AdminService.createSlot(
        name: _nameCtrl.text.trim(),
        startTime: _startTimeCtrl.text.trim(),
        endTime: _endTimeCtrl.text.trim(),
        capacity: cap,
        status: _status,
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
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Slot Name *'),
                          _textField(
                            controller: _nameCtrl,
                            hint: 'e.g. Morning Batch',
                            validator: (v) =>
                                v!.isEmpty ? 'Slot name is required' : null,
                          ),
                          const SizedBox(height: 16),

                          _label('Start Time *'),
                          GestureDetector(
                            onTap: () => _pickTime(_startTimeCtrl),
                            child: AbsorbPointer(
                              child: _textField(
                                controller: _startTimeCtrl,
                                hint: '06:00 AM',
                                suffixIcon: const Icon(
                                  Icons.access_time_outlined,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                validator: (v) => v!.isEmpty
                                    ? 'Start time is required'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _label('End Time *'),
                          GestureDetector(
                            onTap: () => _pickTime(_endTimeCtrl),
                            child: AbsorbPointer(
                              child: _textField(
                                controller: _endTimeCtrl,
                                hint: '09:00 AM',
                                suffixIcon: const Icon(
                                  Icons.access_time_outlined,
                                  size: 18,
                                  color: AppTheme.textSecondary,
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'End time is required' : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _label('Capacity (max members) *'),
                          _textField(
                            controller: _capacityCtrl,
                            hint: '30',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v!.isEmpty) return 'Capacity is required';
                              if (int.tryParse(v) == null || int.parse(v) < 1)
                                return 'Enter a valid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _label('Status *'),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _status = 'active'),
                                  child: _statusBtn(
                                    label: 'Active',
                                    icon: Icons.check_circle_outline,
                                    isSelected: _status == 'active',
                                    color: AppTheme.active,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _status = 'inactive'),
                                  child: _statusBtn(
                                    label: 'Inactive',
                                    icon: Icons.pause_circle_outline,
                                    isSelected: _status == 'inactive',
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
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
          Text(
            _isEdit ? 'Edit Slot' : 'Add New Slot',
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

  Widget _statusBtn({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: isSelected ? color : AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? color : AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : AppTheme.textSecondary,
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
        suffixIcon: suffixIcon,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/utils/theme.dart';

class TrainerFormPage extends StatefulWidget {
  final int? trainerId;
  const TrainerFormPage({super.key, this.trainerId});

  @override
  State<TrainerFormPage> createState() => _TrainerFormPageState();
}

class _TrainerFormPageState extends State<TrainerFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _gender;
  // training_slot is now a slot NAME from the real slots table
  String? _trainingSlotId; // selected slot id (as string)
  bool _isActive = true;
  bool _isLoading = false;
  bool _isFetching = false;
  bool _passwordVisible = false;

  // Real slots fetched from the DB
  List<Map<String, dynamic>> _slots = [];

  bool get _isEditing => widget.trainerId != null;

  final List<String> _genders = ['male', 'female'];

  @override
  void initState() {
    super.initState();
    _loadSlots().then((_) {
      if (_isEditing) _loadTrainer();
    });
  }

  Future<void> _loadSlots() async {
    final result = await AdminService.getSlots(activeOnly: false);
    if (!mounted) return;
    if (result['success']) {
      setState(() {
        _slots = List<Map<String, dynamic>>.from(result['slots']);
        // Default to first slot if none selected yet
        if (_trainingSlotId == null && _slots.isNotEmpty) {
          _trainingSlotId = _slots[0]['id'].toString();
        }
      });
    }
  }

  Future<void> _loadTrainer() async {
    setState(() => _isFetching = true);
    final result = await AdminService.getTrainerById(widget.trainerId!);
    if (result['success']) {
      final t = result['trainer'] as Map<String, dynamic>;
      _nameCtrl.text = t['name'] ?? '';
      _emailCtrl.text = t['email'] ?? '';
      _phoneCtrl.text = t['phone'] ?? '';
      _specCtrl.text = t['specialization'] ?? '';
      _expCtrl.text = t['experience']?.toString() ?? '';
      _gender = t['gender'];

      // Match the stored training_slot string to a slot id
      // The trainer's training_slot stores the slot NAME (e.g. "Morning Batch")
      // or the old enum value (e.g. "morning") — handle both
      final storedSlot = (t['training_slot'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final matched = _slots.firstWhere(
        (s) =>
            s['id'].toString() == storedSlot ||
            (s['name'] ?? '').toString().toLowerCase().trim() == storedSlot ||
            _slotNameMatchesEnum(s['name'] ?? '', storedSlot),
        orElse: () => {},
      );
      if (matched.isNotEmpty) {
        _trainingSlotId = matched['id'].toString();
      } else if (_slots.isNotEmpty) {
        _trainingSlotId = _slots[0]['id'].toString();
      }

      _isActive =
          t['is_active'] == 1 ||
          t['is_active'] == true ||
          t['is_active'].toString() == '1';
    }
    setState(() => _isFetching = false);
  }

  // Maps old hardcoded enum values to slot name keywords
  bool _slotNameMatchesEnum(String slotName, String enumVal) {
    final n = slotName.toLowerCase();
    switch (enumVal) {
      case 'morning':
        return n.contains('morning');
      case 'midday':
        return n.contains('mid') || n.contains('midday');
      case 'evening':
        return n.contains('evening');
      case 'night':
        return n.contains('night');
      default:
        return false;
    }
  }

  // for real slot
  String get _resolvedSlotName {
    if (_trainingSlotId == null)
      return _slots.isNotEmpty ? (_slots[0]['name'] ?? 'morning') : 'morning';
    final slot = _slots.firstWhere(
      (s) => s['id'].toString() == _trainingSlotId,
      orElse: () => {},
    );
    if (slot.isEmpty) return 'morning';
    return (slot['name'] ?? 'morning').toString();
  }

  //
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Map<String, dynamic> result;

    if (_isEditing) {
      result = await AdminService.updateTrainer(
        id: widget.trainerId!,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        gender: _gender,
        specialization: _specCtrl.text.trim(),
        experience: int.tryParse(_expCtrl.text.trim()),
        trainingSlot: _resolvedSlotName, // for real slot
        isActive: _isActive ? 1 : 0,
      );
    } else {
      result = await AdminService.createTrainer(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        gender: _gender,
        specialization: _specCtrl.text.trim(),
        experience: int.tryParse(_expCtrl.text.trim()),
        trainingSlot: _resolvedSlotName, // for real slot
        password: _passwordCtrl.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (result['success']) {
      Get.snackbar(
        _isEditing ? 'Updated' : 'Created',
        _isEditing
            ? '${_nameCtrl.text.trim()} has been updated'
            : '${_nameCtrl.text.trim()} added as trainer',
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
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _specCtrl.dispose();
    _expCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Trainer' : 'Add Trainer',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: _isFetching
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
                    _sectionLabel('Basic Information'),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'e.g. Ahmed Khan',
                      icon: Icons.person_outline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'trainer@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _phoneCtrl,
                      label: 'Phone (optional)',
                      hint: '+92 300 0000000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildGenderDropdown(),

                    if (!_isEditing) ...[
                      const SizedBox(height: 12),
                      _buildPasswordField(),
                    ],

                    const SizedBox(height: 20),
                    _sectionLabel('Professional Info'),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _specCtrl,
                      label: 'Specialization (optional)',
                      hint: 'e.g. Strength & Conditioning',
                      icon: Icons.fitness_center_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _expCtrl,
                      label: 'Experience (years, optional)',
                      hint: '3',
                      icon: Icons.workspace_premium_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 12),

                    // ── Real slots dropdown ──────────────────────────
                    _buildRealSlotDropdown(),

                    if (_isEditing) ...[
                      const SizedBox(height: 20),
                      _sectionLabel('Status'),
                      const SizedBox(height: 8),
                      _buildActiveToggle(),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing ? 'Update Trainer' : 'Add Trainer',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Real Slots Dropdown ─────────────────────────────────────
  Widget _buildRealSlotDropdown() {
    return DropdownButtonFormField<String>(
      value: _trainingSlotId,
      decoration: InputDecoration(
        labelText: 'Training Slot',
        prefixIcon: const Icon(
          Icons.schedule_outlined,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
      hint: Text(
        _slots.isEmpty ? 'Loading slots...' : 'Select a slot',
        style: const TextStyle(fontSize: 14, color: AppTheme.textHint),
      ),
      items: _slots.map((slot) {
        final id = slot['id'].toString();
        final name = slot['name'] ?? '';
        final start = slot['start_time'] ?? '';
        final end = slot['end_time'] ?? '';
        final label = start.isNotEmpty && end.isNotEmpty
            ? '$name  ($start – $end)'
            : name;
        return DropdownMenuItem<String>(
          value: id,
          child: Text(label, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (v) => setState(() => _trainingSlotId = v),
    );
  }

  // ── Password field ──────────────────────────────────────────
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: !_passwordVisible,
      validator: (v) => v == null || v.trim().isEmpty
          ? 'Password is required'
          : v.trim().length < 6
          ? 'Minimum 6 characters'
          : null,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Assign a password',
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          icon: Icon(
            _passwordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: AppTheme.textSecondary,
          ),
          tooltip: _passwordVisible ? 'Hide password' : 'Show password',
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.expired),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textSecondary),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.expired),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(
          Icons.wc_outlined,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
      hint: const Text(
        'Select',
        style: TextStyle(fontSize: 14, color: AppTheme.textHint),
      ),
      items: _genders.map((g) {
        return DropdownMenuItem(
          value: g,
          child: Text(
            g.isEmpty ? g : '${g[0].toUpperCase()}${g.substring(1)}',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _gender = v),
    );
  }

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.toggle_on_outlined,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Active',
              style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
          ),
          Switch(
            value: _isActive,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _isActive = v),
          ),
        ],
      ),
    );
  }
}

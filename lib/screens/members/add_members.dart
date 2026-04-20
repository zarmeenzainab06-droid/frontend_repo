import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/theme.dart';

class AddMemberPage extends StatefulWidget {
  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final packageController = TextEditingController();
  final trainerController = TextEditingController();
  final slotController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (startDate == null || endDate == null) {
      Get.snackbar('Error', 'Select membership dates',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    // TODO: call API here
    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    Get.back();
    Get.snackbar('Success', 'Member added successfully',
        backgroundColor: AppTheme.primary, colorText: Colors.white);
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(nameController, 'Full Name'),
              const SizedBox(height: 12),

              _input(phoneController, 'Phone Number',
                  keyboard: TextInputType.phone),
              const SizedBox(height: 12),

              _input(packageController, 'Package (e.g. Monthly)'),
              const SizedBox(height: 12),

              _input(trainerController, 'Trainer Name'),
              const SizedBox(height: 12),

              _input(slotController, 'Slot (e.g. Morning)'),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: 'Start Date',
                      value: startDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateField(
                      label: 'End Date',
                      value: endDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: AppTheme.textDark),
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          value == null
              ? label
              : "${value.day}/${value.month}/${value.year}",
          style: TextStyle(
            color: value == null ? AppTheme.textGrey : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
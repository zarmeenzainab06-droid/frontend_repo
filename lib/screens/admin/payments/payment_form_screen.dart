import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '/core/utils/theme.dart';
import 'payment_controller.dart';

class PaymentFormPage extends StatelessWidget {
  const PaymentFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PaymentController>();
    final isEdit = c.editingPayment != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildTopBar(context, isEdit),
          Expanded(
            child: Form(
              key: c.formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Member ──────────────────────────────────────────────
                  _label('Member *'),
                  if (isEdit)
                    Obx(
                      () => _readOnlyField(
                        icon: Icons.person,
                        text: c.selectedMember.value?['name']?.toString() ?? '',
                        subText: c.selectedMember.value?['phone']?.toString(),
                        trailing: _packageBadge(
                          c.selectedMember.value?['package_name']?.toString(),
                        ),
                      ),
                    )
                  else
                    Obx(
                      () => DropdownButtonFormField<Map<String, dynamic>>(
                        value: c.selectedMember.value,
                        hint: const Text('Select member'),
                        isExpanded: true,
                        decoration: _decor(Icons.person_outline),
                        items: c.members.map((m) {
                          final name = m['name']?.toString() ?? '';
                          final phone = m['phone']?.toString() ?? '';

                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: m,
                            child: Text(
                              phone.isNotEmpty ? '$name • $phone' : name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: c.onMemberSelected,
                        validator: (v) =>
                            v == null ? 'Please select a member' : null,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ── Package ─────────────────────────────────────────────
                  _label('Package'),
                  Obx(
                    () => _readOnlyField(
                      icon: Icons.fitness_center,
                      text:
                          c.selectedMember.value?['package_name']?.toString() ??
                          '',
                      hint: c.selectedMember.value != null
                          ? 'No package assigned'
                          : 'Auto-populated',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Membership Month ─────────────────────────────────────
                  _label('Membership Month *'),
                  Obx(
                    () => InkWell(
                      onTap: () => c.pickMonth(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                c.selectedMonth.value.isNotEmpty
                                    ? c.selectedMonth.value
                                    : '---------- ----',
                                style: TextStyle(
                                  color: c.selectedMonth.value.isNotEmpty
                                      ? AppTheme.textPrimary
                                      : AppTheme.textHint,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Package Amount ───────────────────────────────────────
                  _label('Package Amount'),
                  Obx(
                    () => _readOnlyField(
                      icon: Icons.currency_rupee,
                      text: c.packageAmount.value > 0
                          ? c.packageAmount.value.toStringAsFixed(0)
                          : '',
                      hint: 'Auto-loaded',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Amount Received ──────────────────────────────────────
                  _label('Amount Received *'),
                  TextFormField(
                    controller: c.amountReceivedController,
                    keyboardType: TextInputType.number,
                    decoration: _decor(
                      Icons.payments_outlined,
                    ).copyWith(hintText: 'Enter amount received'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null)
                        return 'Enter valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Payment Status ───────────────────────────────────────
                  _label('Payment Status *'),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value:
                          [
                            'Pending',
                            'Paid',
                            'Partial',
                            'Unpaid',
                          ].contains(c.selectedStatus.value)
                          ? c.selectedStatus.value
                          : null,
                      hint: const Text('Select status'),
                      isExpanded: true,
                      decoration: _decor(Icons.check_circle_outline),
                      items: ['Pending', 'Paid', 'Partial', 'Unpaid']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: s == 'Paid'
                                          ? AppTheme.active
                                          : s == 'Partial'
                                          ? AppTheme.pending
                                          : AppTheme.expired,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(s),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => c.selectedStatus.value = v!,
                      validator: (v) =>
                          v == null ? 'Please select a status' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Payment Method ───────────────────────────────────────
                  _label('Payment Method *'),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: ['cash', 'online'].map((method) {
                          final selected = c.selectedMethod.value == method;
                          return RadioListTile<String>(
                            value: method,
                            groupValue: c.selectedMethod.value,
                            onChanged: (v) {
                              c.selectedMethod.value = v!;
                              // switching to cash clears new screenshot
                              // but keeps existingScreenshot intact
                              if (v == 'cash') {
                                c.screenshotBytes.value = null;
                                c.screenshotName.value = '';
                              }
                            },
                            activeColor: AppTheme.primary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            dense: true,
                            title: Text(
                              method == 'cash' ? 'Cash' : 'Online',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: selected
                                    ? AppTheme.textDark
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Online-only fields ───────────────────────────────────
                  Obx(() {
                    if (c.selectedMethod.value != 'online') {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction ID
                        _label('Transaction ID *'),
                        TextFormField(
                          controller: c.transactionIdController,
                          decoration: _decor(
                            Icons.tag,
                          ).copyWith(hintText: 'Enter transaction ID'),
                          validator: (v) {
                            if (c.selectedMethod.value == 'online' &&
                                (v == null || v.isEmpty)) {
                              return 'Transaction ID required for online payment';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Screenshot
                        _label(
                          isEdit
                              ? 'Payment Screenshot (optional — keep old if not changed)'
                              : 'Upload Screenshot / Receipt *',
                        ),
                        Obx(() => _buildScreenshotPicker(c, isEdit)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // ── Payment Date ─────────────────────────────────────────
                  _label('Payment Date *'),
                  TextFormField(
                    controller: c.paymentDateController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppTheme.primary,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        c.paymentDateController.text =
                            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      }
                    },
                    decoration: _decor(
                      Icons.date_range_outlined,
                    ).copyWith(hintText: 'mm/dd/yyyy'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please pick a date' : null,
                  ),
                  const SizedBox(height: 32),

                  // ── Save Button ──────────────────────────────────────────
                  Obx(
                    () => ElevatedButton.icon(
                      onPressed: c.isFormLoading.value ? null : c.savePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        disabledBackgroundColor: AppTheme.primary.withOpacity(
                          0.6,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                      ),
                      icon: c.isFormLoading.value
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
                              color: Colors.white,
                              size: 18,
                            ),
                      label: Text(
                        c.isFormLoading.value
                            ? 'Saving...'
                            : (isEdit ? 'Update Payment' : 'Save Payment'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SCREENSHOT PICKER — same pattern as MemberFormPage ───────────────────
  Widget _buildScreenshotPicker(PaymentController c, bool isEdit) {
    final hasNew = c.screenshotBytes.value != null;
    final hasExisting = c.existingScreenshot.value.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (picked != null) {
          final bytes = await picked.readAsBytes();
          c.screenshotBytes.value = bytes;
          c.screenshotName.value = picked.name;
          c.existingScreenshot.value = ''; // replaced by new
        }
      },
      child: Container(
        width: double.infinity,
        height: (hasNew || hasExisting) ? 180 : 110,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: (hasNew || hasExisting) ? AppTheme.active : AppTheme.border,
          ),
        ),
        child: _screenshotPreviewContent(c, hasNew, hasExisting, isEdit),
      ),
    );
  }

  Widget _screenshotPreviewContent(
    PaymentController c,
    bool hasNew,
    bool hasExisting,
    bool isEdit,
  ) {
    // New screenshot picked by user
    if (hasNew) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(c.screenshotBytes.value!, fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: _changeBtn(() async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked != null) {
                  c.screenshotBytes.value = await picked.readAsBytes();
                  c.screenshotName.value = picked.name;
                }
              }),
            ),
          ],
        ),
      );
    }

    // Existing screenshot from server (edit mode)
    if (hasExisting) {
      // Build URL same way as AdminService.baseUrl
      final raw = c.existingScreenshot.value.replaceAll('\\', '/');
      //final url = 'http://gym.sandbox.pk/$raw';
      final url = 'http://gym.sandbox.pk/uploads/${c.existingScreenshot.value}';

      print('Image URL: $url');
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
              child: _changeBtn(() async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  c.screenshotBytes.value = bytes;
                  c.screenshotName.value = picked.name;
                  c.existingScreenshot.value = ''; // replaced
                }
              }),
            ),
          ],
        ),
      );
    }

    // Empty state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.upload_outlined, size: 32, color: AppTheme.textHint),
        const SizedBox(height: 8),
        Text(
          isEdit
              ? 'Tap to upload new screenshot'
              : 'Click to upload screenshot',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const Text(
          'PNG, JPG up to 10MB',
          style: TextStyle(fontSize: 11, color: AppTheme.textHint),
        ),
      ],
    );
  }

  Widget _changeBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Change',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, bool isEdit) {
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 4,
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
            isEdit ? 'Edit Payment' : 'Add Payment',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppTheme.textPrimary,
      ),
    ),
  );

  Widget _packageBadge(String? name) {
    if (name == null || name.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _readOnlyField({
    required IconData icon,
    required String text,
    String? hint,
    String? subText,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text.isNotEmpty ? text : (hint ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    color: text.isNotEmpty
                        ? AppTheme.textPrimary
                        : AppTheme.textHint,
                    fontWeight: text.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (subText != null && subText.isNotEmpty)
                  Text(
                    subText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  InputDecoration _decor(IconData icon) => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
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
      borderSide: const BorderSide(color: AppTheme.expired, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

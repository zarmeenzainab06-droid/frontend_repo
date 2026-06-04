import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:third_task/core/utils/theme.dart';
import 'payment_controller.dart';
import '../../../screens/admin/payments/payment_model.dart';
import '../../../core/widgets/app_shell.dart'; // AppShell, AdminBottomNav
import '../../../core/utils/theme.dart';

class ManagePaymentsScreen extends StatelessWidget {
  const ManagePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());

    return AppShell(
      role: 'admin',
      subtitle: 'Payments',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        return Stack(
          children: [
            Column(
              children: [
                _buildStatsRow(controller),
                _buildSearchAndFilter(controller),
                Expanded(child: _buildPaymentsList(context, controller)),
              ],
            ),
            // FAB
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  controller.openAddForm();
                  _showPaymentDialog(context, controller);
                },
                backgroundColor: AppTheme.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNav: const AdminBottomNav(
        activeIndex: -1,
      ), // payments not in bottom nav
      actions: [
        AppShellAction(
          icon: Icons.refresh,
          onTap: controller.loadPayments,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  // ─── STATS ROW ────────────────────────────────────────────────────────────
  Widget _buildStatsRow(PaymentController c) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Obx(
        () => Row(
          children: [
            _statCard('Paid', c.totalPaid.toString(), AppTheme.active),
            const SizedBox(width: 8),
            _statCard('Unpaid', c.totalUnpaid.toString(), AppTheme.expired),
            const SizedBox(width: 8),
            _statCard('Partial', c.totalPartial.toString(), AppTheme.pending),
            const SizedBox(width: 8),
            _statCard(
              'Revenue',
              'Rs ${c.totalRevenue.toStringAsFixed(0)}',
              Colors.white,
              flex: 2,
              isRevenue: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    Color color, {
    int flex = 1,
    bool isRevenue = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isRevenue
              ? Colors.white.withOpacity(0.15)
              : color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isRevenue
                ? Colors.white.withOpacity(0.3)
                : color.withOpacity(0.35),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SEARCH & FILTER ──────────────────────────────────────────────────────
  Widget _buildSearchAndFilter(PaymentController c) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => c.searchQuery.value = v,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by member name...',
                hintStyle: const TextStyle(color: AppTheme.textHint),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primary,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: c.filterStatus.value,
                  items: ['All', 'Paid', 'Unpaid', 'Partial']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => c.filterStatus.value = v!,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PAYMENTS LIST ────────────────────────────────────────────────────────
  Widget _buildPaymentsList(BuildContext context, PaymentController c) {
    return Obx(() {
      final list = c.filteredPayments;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment_outlined, size: 64, color: AppTheme.textHint),
              const SizedBox(height: 12),
              Text(
                'No payments found',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: list.length,
        itemBuilder: (ctx, i) => _paymentCard(ctx, list[i], c),
      );
    });
  }

  Widget _paymentCard(
    BuildContext context,
    PaymentModel payment,
    PaymentController c,
  ) {
    final statusColor = payment.paymentStatus.toLowerCase() == 'paid'
        ? AppTheme.active
        : payment.paymentStatus.toLowerCase() == 'partial'
        ? AppTheme.pending
        : AppTheme.expired;

    final statusLight = payment.paymentStatus.toLowerCase() == 'paid'
        ? AppTheme.activeLight
        : payment.paymentStatus.toLowerCase() == 'partial'
        ? AppTheme.pendingLight
        : AppTheme.expiredLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            // ── Header ──
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      payment.memberName.isNotEmpty
                          ? payment.memberName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
                        payment.memberName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payment.packageName.isNotEmpty
                            ? payment.packageName
                            : 'No package',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    payment.paymentStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20, color: AppTheme.border),

            // ── Details ──
            Row(
              children: [
                _chip(
                  Icons.calendar_month_outlined,
                  payment.membershipMonth.isNotEmpty
                      ? payment.membershipMonth
                      : 'No month',
                ),
                const SizedBox(width: 10),
                _chip(
                  Icons.currency_rupee,
                  'Pkg: Rs ${payment.packageAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(width: 10),
                _chip(
                  Icons.payments_outlined,
                  'Paid: Rs ${payment.amountReceived.toStringAsFixed(0)}',
                  color: AppTheme.active,
                ),
              ],
            ),

            // ── Actions ──
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionBtn(Icons.edit_outlined, 'Edit', AppTheme.primary, () {
                  c.openEditForm(payment);
                  _showPaymentDialog(context, c);
                }),
                const SizedBox(width: 8),
                _actionBtn(
                  Icons.delete_outline,
                  'Delete',
                  AppTheme.expired,
                  () => _confirmDelete(context, payment, c),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color ?? AppTheme.textSecondary,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ADD / EDIT DIALOG ────────────────────────────────────────────────────
  void _showPaymentDialog(BuildContext context, PaymentController c) {
    final isEdit = c.editingPayment != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: c.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? 'Edit Payment' : 'Add Payment',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Select Member ──
                _label('Select Member *'),
                Obx(
                  () => DropdownButtonFormField<Map<String, dynamic>>(
                    value: c.selectedMember.value,
                    hint: const Text('Choose a member'),
                    isExpanded: true,
                    decoration: _decor(Icons.person_outline),
                    items: c.members
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m['name'] ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: c.onMemberSelected,
                    validator: (v) =>
                        v == null ? 'Please select a member' : null,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Package (auto-loaded) ──
                _label('Package'),
                Obx(
                  () => TextFormField(
                    readOnly: true,
                    decoration: _decor(Icons.fitness_center).copyWith(
                      hintText: c.selectedMember.value != null
                          ? (c.selectedMember.value!['package_name'] ??
                                'No package assigned')
                          : 'Auto-loaded after member selection',
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                    controller: TextEditingController(
                      text: c.selectedMember.value?['package_name'] ?? '',
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Membership Month ──
                _label('Membership Month *'),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: c.selectedMonth.value.isNotEmpty
                        ? c.selectedMonth.value
                        : null,
                    hint: const Text('Select month'),
                    isExpanded: true,
                    decoration: _decor(Icons.calendar_month_outlined),
                    items: c.monthOptions
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => c.selectedMonth.value = v!,
                    validator: (v) =>
                        v == null ? 'Please select a month' : null,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Package Amount (auto-loaded) ──
                _label('Package Amount'),
                Obx(
                  () => TextFormField(
                    readOnly: true,
                    decoration: _decor(Icons.currency_rupee).copyWith(
                      hintText: 'Auto-loaded from package',
                      filled: true,
                      fillColor: AppTheme.background,
                    ),
                    controller: TextEditingController(
                      text: c.packageAmount.value > 0
                          ? c.packageAmount.value.toStringAsFixed(0)
                          : '',
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Amount Received ──
                _label('Amount Received *'),
                TextFormField(
                  controller: c.amountReceivedController,
                  keyboardType: TextInputType.number,
                  decoration: _decor(
                    Icons.payments_outlined,
                  ).copyWith(hintText: 'Enter amount received'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Enter valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Payment Status ──
                _label('Payment Status *'),
                Obx(
                  () => Row(
                    children: ['Paid', 'Partial', 'Unpaid'].map((status) {
                      final selected = c.selectedStatus.value == status;
                      final color = status == 'Paid'
                          ? AppTheme.active
                          : status == 'Partial'
                          ? AppTheme.pending
                          : AppTheme.expired;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => c.selectedStatus.value = status,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: selected ? color : color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                              border: Border.all(
                                color: color.withOpacity(selected ? 1 : 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: selected ? Colors.white : color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Payment Date ──
                _label('Payment Date (optional)'),
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
                  ).copyWith(hintText: 'Pick a date'),
                ),
                const SizedBox(height: 24),

                // ── Save Button ──
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: c.isFormLoading.value ? null : c.savePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        disabledBackgroundColor: AppTheme.primary.withOpacity(
                          0.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                      ),
                      child: c.isFormLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEdit ? 'Update Payment' : 'Save Payment',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── DELETE DIALOG ────────────────────────────────────────────────────────
  void _confirmDelete(
    BuildContext context,
    PaymentModel payment,
    PaymentController c,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Delete Payment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        content: Text(
          'Remove payment record for ${payment.memberName}'
          '${payment.membershipMonth.isNotEmpty ? " (${payment.membershipMonth})" : ""}?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              c.deletePayment(payment.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expired,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  Widget _label(String text) {
    return Padding(
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
  }

  InputDecoration _decor(IconData icon) {
    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:third_task/core/utils/theme.dart';
import 'package:third_task/screens/admin/payments/payment_form_screen.dart';
import 'payment_controller.dart';
import '../../../screens/admin/payments/payment_model.dart';
import '../../../core/widgets/app_shell.dart';

class ManagePaymentsScreen extends StatelessWidget {
  const ManagePaymentsScreen({super.key});

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'partial':
        return 'Partial';

      case 'pending':
        return 'Pending';
      case 'unpaid':
        return 'Unpaid';
      default:
        return s.isEmpty ? 'Unpaid' : s;
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
        return AppTheme.active;
      case 'partial':
        return AppTheme.pending;
      case 'pending':
        return const Color.fromARGB(255, 17, 0, 255);
      default:
        return AppTheme.expired;
    }
  }

  Color _statusLight(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
        return AppTheme.activeLight;

      case 'partial':
        return AppTheme.pendingLight;

      case 'pending':
        return AppTheme.pendingLight;

      case 'unpaid':
        return AppTheme.expiredLight;

      default:
        return AppTheme.expiredLight;
    }
  }

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
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  controller.openAddForm();
                  // ← navigate to full page instead of dialog
                  Get.to(() => const PaymentFormPage());
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
      bottomNav: const AdminBottomNav(activeIndex: -1),
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
            _statCard(
              'Paid',
              c.totalPaid.toString(),
              const Color.fromARGB(255, 32, 207, 38),
            ),
            const SizedBox(width: 8),
            _statCard('Unpaid', c.totalUnpaid.toString(), AppTheme.expired),
            const SizedBox(width: 8),
            _statCard('pending', c.totalpending.toString(), AppTheme.pending),
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
                  items: ['All', 'Paid', 'Pending', 'Partial', 'Unpaid']
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

  // ─── PAYMENT CARD ─────────────────────────────────────────────────────────
  // ── FOR STATUS UPDATE ───────

  Widget _paymentCard(
    BuildContext context,
    PaymentModel payment,
    PaymentController c,
  ) {
    final label = _statusLabel(payment.paymentStatus);
    final color = _statusColor(payment.paymentStatus);
    final light = _statusLight(payment.paymentStatus);
    final isPending = payment.paymentStatus.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
        // highlight pending cards with a left border
        border: isPending
            ? Border(left: BorderSide(color: AppTheme.pending, width: 4))
            : null,
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
                  decoration: const BoxDecoration(
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
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPending ? AppTheme.pendingLight : light,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPending
                          ? AppTheme.pending.withOpacity(0.4)
                          : color.withOpacity(0.35),
                    ),
                  ),
                  child: Text(
                    isPending ? 'Pending' : label,
                    style: TextStyle(
                      color: isPending ? AppTheme.pending : color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20, color: AppTheme.border),

            // ── Details ──
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _chip(
                  Icons.calendar_month_outlined,
                  payment.membershipMonth.isNotEmpty
                      ? payment.membershipMonth
                      : 'No month',
                ),
                _chip(
                  Icons.currency_rupee,
                  'Pkg: Rs ${payment.packageAmount.toStringAsFixed(0)}',
                ),
                _chip(
                  Icons.payments_outlined,
                  'Paid: Rs ${payment.amountReceived.toStringAsFixed(0)}',
                  color: AppTheme.active,
                ),
                _chip(
                  payment.method == 'online'
                      ? Icons.phone_android_outlined
                      : Icons.payments_outlined,
                  payment.method == 'online' ? 'Online' : 'Cash',
                  color: payment.method == 'online'
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Pending: show approve buttons ────────────────────────────
            if (isPending) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.pendingLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.pending.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppTheme.pending,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Payment pending approval',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.pending,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Mark as Paid
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmStatusChange(
                              context,
                              payment,
                              c,
                              'paid',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.active,
                              minimumSize: const Size(0, 38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSm,
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Mark Paid',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Mark as Partial
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmStatusChange(
                              context,
                              payment,
                              c,
                              'partial',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.pending,
                              minimumSize: const Size(0, 38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSm,
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Partial',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reject
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmStatusChange(
                              context,
                              payment,
                              c,
                              'unpaid',
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              side: BorderSide(
                                color: AppTheme.expired.withOpacity(0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSm,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.cancel_outlined,
                              size: 16,
                              color: AppTheme.expired,
                            ),
                            label: Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.expired,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // ── Normal actions ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionBtn(Icons.edit_outlined, 'Edit', AppTheme.primary, () {
                  c.openEditForm(payment);
                  Get.to(() => const PaymentFormPage());
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

  // ── Add this confirm dialog method to ManagePaymentsScreen ────────────────

  void _confirmStatusChange(
    BuildContext context,
    PaymentModel payment,
    PaymentController c,
    String newStatus,
  ) {
    final color = newStatus == 'paid'
        ? AppTheme.active
        : newStatus == 'partial'
        ? AppTheme.pending
        : AppTheme.expired;
    final label = newStatus == 'paid'
        ? 'Paid'
        : newStatus == 'partial'
        ? 'Partial'
        : 'Unpaid (Reject)';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Mark as $label',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        content: Text(
          'Mark ${payment.memberName}\'s payment of '
          'Rs ${payment.amountReceived.toStringAsFixed(0)} as $label?',
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
              c.updateStatus(payment.id!, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: Text(
              'Confirm',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
}

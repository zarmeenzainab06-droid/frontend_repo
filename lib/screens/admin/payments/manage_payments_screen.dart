import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/theme.dart';
import 'package:GymFitex/screens/admin/payments/payment_form_screen.dart';
import 'payment_controller.dart';
import '../../../screens/admin/payments/payment_model.dart';
import '../../../core/widgets/app_shell.dart';

class ManagePaymentsScreen extends StatelessWidget {
  const ManagePaymentsScreen({super.key});

  // ---------- status helpers (logic unchanged) ----------
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
        return const Color(0xFF1100FF);
      default:
        return AppTheme.expired;
    }
  }

  Color _statusBg(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
        return AppTheme.activeLight;
      case 'partial':
      case 'pending':
        return AppTheme.pendingLight;
      default:
        return AppTheme.expiredLight;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'paid':
        return Icons.check_circle_rounded;
      case 'partial':
        return Icons.donut_small_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.cancel_rounded;
    }
  }

  // ---------- color helpers (same pattern as Members screen) ----------
  Color _lighten(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PaymentController());

    return AppShell(
      role: 'admin',
      subtitle: 'GymFitex',
      bottomNav: const AdminBottomNav(activeIndex: -1),
      actions: [
        AppShellAction(
          icon: Icons.refresh,
          onTap: c.loadPayments,
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(children: [_buildHeader(c), const SizedBox(height: 70)]),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: _buildControlsCard(c),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Obx(() {
                final list = c.filteredPayments;
                if (list.isEmpty) return _buildEmpty();
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: c.loadPayments,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => _paymentCard(ctx, list[i], c),
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  // ---------- header (compact gradient hero, no decorative circles) ----------
  Widget _buildHeader(PaymentController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 56),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _darken(AppTheme.primary, 0.18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Manage Payments',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              _GlassButton(
                icon: Icons.add_rounded,
                label: 'Add',
                onTap: () {
                  c.openAddForm();
                  Get.to(() => const PaymentFormPage());
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                _headerStatChip('Paid', c.totalPaid),
                const SizedBox(width: 8),
                _headerStatChip('Pending', c.totalpending),
                const SizedBox(width: 8),
                _headerStatChip('Unpaid', c.totalUnpaid),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStatChip(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- floating glass search + filter card ----------
  Widget _buildControlsCard(PaymentController c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => c.searchQuery.value = v,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by member name...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppTheme.textHint,
                size: 20,
              ),
              filled: true,
              fillColor: AppTheme.background,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: Obx(() {
              // Read .value here (synchronously, inside the Obx builder) so GetX
              // actually registers it as a dependency. Reading it lazily inside
              // a ListView.builder's itemBuilder happens too late for Obx to see.
              const options = ['All', 'Paid', 'Pending', 'Partial', 'Unpaid'];
              final selectedOption = c.filterStatus.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(options.length, (i) {
                    final option = options[i];
                    final selected = option == selectedOption;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: i == options.length - 1 ? 0 : 8,
                      ),
                      child: GestureDetector(
                        onTap: () => c.filterStatus.value = option,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: selected
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.primary,
                                      _lighten(AppTheme.primary, 0.08),
                                    ],
                                  )
                                : null,
                            color: selected ? null : AppTheme.background,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? Colors.transparent
                                  : AppTheme.border,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(
    BuildContext context,
    PaymentModel payment,
    PaymentController c,
  ) {
    final status = payment.paymentStatus;
    final label = _statusLabel(status);
    final color = _statusColor(status);
    final bg = _statusBg(status);
    final isPending = status.toLowerCase() == 'pending';
    final initial = payment.memberName.isNotEmpty
        ? payment.memberName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.35), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.4)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(21),
                  topRight: Radius.circular(21),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary,
                              _lighten(AppTheme.primary, 0.12),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
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
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              payment.packageName.isNotEmpty
                                  ? payment.packageName
                                  : 'No package',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(status), size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(
                          Icons.calendar_month_outlined,
                          payment.membershipMonth.isNotEmpty
                              ? payment.membershipMonth
                              : 'No month',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.currency_rupee,
                          'Package: Rs ${payment.packageAmount.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          Icons.payments_outlined,
                          'Paid: Rs ${payment.amountReceived.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        _infoRow(
                          payment.method == 'online'
                              ? Icons.phone_android_outlined
                              : Icons.account_balance_wallet_outlined,
                          payment.method == 'online'
                              ? 'Online payment'
                              : 'Cash payment',
                        ),
                      ],
                    ),
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 14),
                    _pendingActions(context, payment, c),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _gradientActionButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          colors: [
                            AppTheme.primary,
                            _lighten(AppTheme.primary, 0.1),
                          ],
                          onTap: () {
                            c.openEditForm(payment);
                            Get.to(() => const PaymentFormPage());
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _outlineActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          color: AppTheme.expired,
                          onTap: () => _confirmDelete(context, payment, c),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingActions(
    BuildContext context,
    PaymentModel payment,
    PaymentController c,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.pendingLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.pending.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: AppTheme.pending),
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
              Expanded(
                child: _gradientActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Mark Paid',
                  colors: [AppTheme.active, _darken(AppTheme.active, 0.1)],
                  onTap: () =>
                      _confirmStatusChange(context, payment, c, 'paid'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _gradientActionButton(
                  icon: Icons.access_time,
                  label: 'Partial',
                  colors: [AppTheme.pending, _darken(AppTheme.pending, 0.1)],
                  onTap: () =>
                      _confirmStatusChange(context, payment, c, 'partial'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _outlineActionButton(
                  icon: Icons.cancel_outlined,
                  label: 'Reject',
                  color: AppTheme.expired,
                  onTap: () =>
                      _confirmStatusChange(context, payment, c, 'unpaid'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- shared small widgets (matches Members screen style) ----------
  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: AppTheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradientActionButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlineActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.15),
                  AppTheme.primary.withOpacity(0.03),
                ],
              ),
            ),
            child: Icon(
              Icons.payment_outlined,
              size: 44,
              color: AppTheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No payments found',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  // ---------- dialogs (logic unchanged, styling matched) ----------
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mark as $label',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          "Mark ${payment.memberName}'s payment of Rs ${payment.amountReceived.toStringAsFixed(0)} as $label?",
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm',
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

  void _confirmDelete(
    BuildContext context,
    PaymentModel payment,
    PaymentController c,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Payment',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Remove payment record for ${payment.memberName}${payment.membershipMonth.isNotEmpty ? " (${payment.membershipMonth})" : ""}?',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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

/// Frosted-glass pill button used in the gradient header (e.g. "Add" payment).
class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  const _GlassButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 17, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

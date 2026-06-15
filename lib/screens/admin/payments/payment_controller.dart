import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:third_task/core/services/admin_payment_service.dart'
    hide debugPrint;
import '../../../screens/admin/payments/payment_model.dart';

class PaymentController extends GetxController {
  // ─── STATE ────────────────────────────────────────────────────────────────
  final RxList<PaymentModel> payments = <PaymentModel>[].obs;
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isFormLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'All'.obs;

  // ─── FORM CONTROLLERS ─────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final amountReceivedController = TextEditingController();
  final paymentDateController = TextEditingController();
  final transactionIdController = TextEditingController(); // ← NEW

  // ─── FORM OBSERVABLES ─────────────────────────────────────────────────────
  final Rx<Map<String, dynamic>?> selectedMember = Rx(null);
  final RxString selectedMonth = ''.obs;
  final RxDouble packageAmount = 0.0.obs;
  final RxString selectedStatus = 'Paid'.obs;
  final RxString selectedMethod = 'cash'.obs; // ← NEW

  // ─── SCREENSHOT (online payment) ──────────────────────────────────────────
  final Rx<Uint8List?> screenshotBytes = Rx(null); // ← NEW
  final RxString screenshotName = ''.obs; // ← NEW
  final RxString existingScreenshot = ''.obs; // ← for edit mode

  // ─── EDITING STATE ────────────────────────────────────────────────────────
  PaymentModel? editingPayment;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
    loadMembers();
    _setCurrentMonth();
  }

  @override
  void onClose() {
    amountReceivedController.dispose();
    paymentDateController.dispose();
    transactionIdController.dispose();
    super.onClose();
  }

  // ─── COMPUTED ─────────────────────────────────────────────────────────────
  List<PaymentModel> get filteredPayments {
    return payments.where((p) {
      final matchSearch =
          searchQuery.isEmpty ||
          p.memberName.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchStatus =
          filterStatus.value == 'All' ||
          p.paymentStatus.toLowerCase() == filterStatus.value.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();
  }

  // total stats of payment
  int get totalPaid =>
      payments.where((p) => p.paymentStatus.toLowerCase() == 'paid').length;
  int get totalUnpaid =>
      payments.where((p) => p.paymentStatus.toLowerCase() == 'unpaid').length;
  int get totalpending =>
      payments.where((p) => p.paymentStatus.toLowerCase() == 'pending').length;

  double get totalRevenue => payments
      .where((p) => p.paymentStatus.toLowerCase() == 'paid')
      .fold(0, (sum, p) => sum + p.amountReceived);

  // ─── LOAD PAYMENTS ────────────────────────────────────────────────────────
  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      payments.value = await PaymentService.getAllPayments();
    } catch (e) {
      debugPrint('loadPayments error: $e');
      Get.snackbar(
        'Error',
        'Failed to load payments',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── LOAD MEMBERS ─────────────────────────────────────────────────────────
  Future<void> loadMembers() async {
    try {
      members.value = await PaymentService.getMembers();
      debugPrint('loadMembers: ${members.length} loaded');
    } catch (e) {
      debugPrint('loadMembers error: $e');
    }
  }

  // ─── MEMBER SELECTED ──────────────────────────────────────────────────────
  void onMemberSelected(Map<String, dynamic>? member) {
    selectedMember.value = member;
    if (member == null) {
      packageAmount.value = 0.0;
      amountReceivedController.clear();
      return;
    }
    final amount =
        double.tryParse(member['package_amount']?.toString() ?? '0') ?? 0.0;
    packageAmount.value = amount;
    if (amount > 0) {
      amountReceivedController.text = amount.toStringAsFixed(0);
    } else {
      amountReceivedController.clear();
    }
  }

  // ─── MONTH PICKER ─────────────────────────────────────────────────────────
  Future<void> pickMonth(BuildContext context) async {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;

    if (selectedMonth.value.isNotEmpty) {
      final parts = selectedMonth.value.split(' ');
      if (parts.length == 2) {
        currentYear = int.tryParse(parts[1]) ?? currentYear;
        final idx = monthNames.indexOf(parts[0]);
        if (idx != -1) currentMonth = idx + 1;
      }
    }

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
            maxWidth: 360,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _MonthYearPickerWidget(
              initialYear: currentYear,
              initialMonth: currentMonth,
              monthNames: monthNames,
              onSelected: (year, month) {
                selectedMonth.value = '${monthNames[month - 1]} $year';
                Get.back();
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── SET CURRENT MONTH ────────────────────────────────────────────────────
  void _setCurrentMonth() => selectedMonth.value = _currentMonth();

  String _currentMonth() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  // ─── OPEN ADD FORM ────────────────────────────────────────────────────────
  void openAddForm() {
    editingPayment = null;
    selectedMember.value = null;
    packageAmount.value = 0.0;
    selectedStatus.value = 'Paid';
    selectedMethod.value = 'cash';
    screenshotBytes.value = null;
    screenshotName.value = '';
    existingScreenshot.value = '';
    transactionIdController.clear();
    amountReceivedController.clear();
    paymentDateController.text = _todayDate();
    _setCurrentMonth();
  }

  // ─── OPEN EDIT FORM ───────────────────────────────────────────────────────
  void openEditForm(PaymentModel payment) {
    editingPayment = payment;

    print('Screenshot from API: ${payment.screenshot}');

    final matched = members.firstWhereOrNull(
      (m) => m['id'] == payment.memberId,
    );
    selectedMember.value =
        matched ??
        {
          'id': payment.memberId,
          'name': payment.memberName,
          'package_id': payment.packageId,
          'package_name': payment.packageName,
          'package_amount': payment.packageAmount,
        };

    packageAmount.value = payment.packageAmount;
    selectedMonth.value = payment.membershipMonth.isNotEmpty
        ? payment.membershipMonth
        : _currentMonth();
    selectedStatus.value = _capitalize(payment.paymentStatus);
    selectedMethod.value = payment.method.isNotEmpty ? payment.method : 'cash';
    existingScreenshot.value = payment.screenshot ?? '';
    screenshotBytes.value = null;
    screenshotName.value = '';
    transactionIdController.text = payment.transactionId ?? '';
    amountReceivedController.text = payment.amountReceived.toStringAsFixed(0);
    paymentDateController.text = payment.paymentDate ?? _todayDate();
  }

  // ─── SAVE ─────────────────────────────────────────────────────────────────
  Future<void> savePayment() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedMember.value == null) {
      Get.snackbar(
        'Validation',
        'Please select a member',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedMonth.value.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please select a membership month',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // Screenshot required for online on ADD
    if (selectedMethod.value == 'online' &&
        editingPayment == null &&
        screenshotBytes.value == null) {
      Get.snackbar(
        'Validation',
        'Please upload a payment screenshot',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final member = selectedMember.value!;
    final payment = PaymentModel(
      id: editingPayment?.id,
      memberId: (member['id'] as num).toInt(),
      memberName: member['name']?.toString() ?? '',
      packageId: member['package_id'] != null
          ? (member['package_id'] as num).toInt()
          : null,
      packageName: member['package_name']?.toString() ?? '',
      membershipMonth: selectedMonth.value,
      packageAmount: packageAmount.value,
      amountReceived: double.tryParse(amountReceivedController.text) ?? 0.0,
      paymentStatus: selectedStatus.value,
      paymentDate: paymentDateController.text.isNotEmpty
          ? paymentDateController.text
          : null,
      method: selectedMethod.value,
      transactionId: selectedMethod.value == 'online'
          ? transactionIdController.text.trim()
          : null,
    );

    debugPrint('Saving payment: ${payment.toJson()}');

    try {
      isFormLoading.value = true;
      bool success;

      if (editingPayment != null) {
        success = await PaymentService.updatePayment(
          editingPayment!.id!,
          payment,
          screenshotBytes: screenshotBytes.value,
          screenshotName: screenshotName.value.isNotEmpty
              ? screenshotName.value
              : null,
        );
      } else {
        success = await PaymentService.addPayment(
          payment,
          screenshotBytes: screenshotBytes.value,
          screenshotName: screenshotName.value.isNotEmpty
              ? screenshotName.value
              : null,
        );
      }

      if (success) {
        Get.back();
        await loadPayments();
        Get.snackbar(
          'Success',
          editingPayment != null ? 'Payment updated!' : 'Payment saved!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Server did not confirm save.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('savePayment error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    } finally {
      isFormLoading.value = false;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  Future<void> deletePayment(int id) async {
    try {
      final success = await PaymentService.deletePayment(id);
      if (success) {
        payments.removeWhere((p) => p.id == id);
        Get.snackbar(
          'Deleted',
          'Payment record removed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('deletePayment error: $e');
    }
  }

  // ── Add this method to PaymentController ──────────────────────────────────
  // FOR UPDATE STATUS

  Future<void> updateStatus(int id, String newStatus) async {
    try {
      final success = await PaymentService.updateStatus(id, newStatus);
      if (success) {
        // Update locally without full reload for instant UI feedback
        final idx = payments.indexWhere((p) => p.id == id);
        if (idx != -1) {
          final old = payments[idx];
          payments[idx] = PaymentModel(
            id: old.id,
            memberId: old.memberId,
            memberName: old.memberName,
            packageId: old.packageId,
            packageName: old.packageName,
            membershipMonth: old.membershipMonth,
            packageAmount: old.packageAmount,
            amountReceived: old.amountReceived,
            paymentStatus: _capitalize(newStatus),
            paymentDate: old.paymentDate,
            createdAt: old.createdAt,
            method: old.method,
            screenshot: old.screenshot,
            transactionId: old.transactionId,
          );
          payments.refresh();
        }
        Get.snackbar(
          'Updated',
          'Payment marked as ${_capitalize(newStatus)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: newStatus.toLowerCase() == 'paid'
              ? const Color(0xFF4CAF50)
              : const Color(0xFFFF9800),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('updateStatus error: $e');
      Get.snackbar(
        'Error',
        'Failed to update status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

// ─── MONTH/YEAR PICKER WIDGET ─────────────────────────────────────────────
class _MonthYearPickerWidget extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final List<String> monthNames;
  final void Function(int year, int month) onSelected;

  const _MonthYearPickerWidget({
    required this.initialYear,
    required this.initialMonth,
    required this.monthNames,
    required this.onSelected,
  });

  @override
  State<_MonthYearPickerWidget> createState() => _MonthYearPickerWidgetState();
}

class _MonthYearPickerWidgetState extends State<_MonthYearPickerWidget> {
  late int _year;
  late int _selectedMonth;

  final _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _selectedMonth = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Month',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(() => _year--),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFFE53935),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                Text(
                  '$_year',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Color(0xFF212121),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _year++),
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFE53935),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final isSelected = _selectedMonth == i + 1;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedMonth = i + 1);
                  widget.onSelected(_year, i + 1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE53935)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE53935)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _shortMonths[i],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF424242),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

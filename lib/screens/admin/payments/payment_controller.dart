import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:third_task/core/services/payment_service.dart';
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

  // ─── FORM OBSERVABLES ─────────────────────────────────────────────────────
  final Rx<Map<String, dynamic>?> selectedMember = Rx(null);
  final RxString selectedMonth = ''.obs;
  final RxDouble packageAmount = 0.0.obs;
  final RxString selectedStatus = 'Paid'.obs;

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
    super.onClose();
  }

  // ─── COMPUTED ─────────────────────────────────────────────────────────────
  List<PaymentModel> get filteredPayments {
    return payments.where((p) {
      final matchSearch =
          searchQuery.isEmpty ||
          p.memberName.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchStatus =
          filterStatus.value == 'All' || p.paymentStatus == filterStatus.value;
      return matchSearch && matchStatus;
    }).toList();
  }

  int get totalPaid => payments.where((p) => p.paymentStatus == 'Paid').length;
  int get totalUnpaid =>
      payments.where((p) => p.paymentStatus == 'Unpaid').length;
  int get totalPartial =>
      payments.where((p) => p.paymentStatus == 'Partial').length;

  double get totalRevenue => payments
      .where((p) => p.paymentStatus == 'Paid')
      .fold(0, (sum, p) => sum + p.amountReceived);

  // ─── LOAD DATA ────────────────────────────────────────────────────────────
  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      payments.value = await PaymentService.getAllPayments();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payments',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF5252),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMembers() async {
    try {
      members.value = await PaymentService.getMembers();
    } catch (_) {}
  }

  // ─── MEMBER SELECTED ──────────────────────────────────────────────────────
  void onMemberSelected(Map<String, dynamic>? member) {
    selectedMember.value = member;
    if (member != null) {
      packageAmount.value =
          double.tryParse(member['package_amount']?.toString() ?? '0') ?? 0.0;
      // Only prefill if package exists
      if (packageAmount.value > 0) {
        amountReceivedController.text = packageAmount.value.toStringAsFixed(0);
      } else {
        amountReceivedController.clear();
      }
    }
  }

  // ─── SET CURRENT MONTH ────────────────────────────────────────────────────
  void _setCurrentMonth() {
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
    selectedMonth.value = '${months[now.month - 1]} ${now.year}';
  }

  // ─── OPEN ADD FORM ────────────────────────────────────────────────────────
  void openAddForm() {
    editingPayment = null;
    selectedMember.value = null;
    packageAmount.value = 0.0;
    selectedStatus.value = 'Paid';
    amountReceivedController.clear();
    paymentDateController.text = _todayDate();
    _setCurrentMonth();
  }

  // ─── OPEN EDIT FORM ───────────────────────────────────────────────────────
  void openEditForm(PaymentModel payment) {
    editingPayment = payment;

    // Pre-fill member
    try {
      selectedMember.value = members.firstWhere(
        (m) => m['id'] == payment.memberId,
      );
    } catch (_) {
      selectedMember.value = {
        'id': payment.memberId,
        'name': payment.memberName,
        'package_id': payment.packageId,
        'package_name': payment.packageName,
        'package_amount': payment.packageAmount,
      };
    }

    packageAmount.value = payment.packageAmount;
    selectedMonth.value = payment.membershipMonth;
    amountReceivedController.text = payment.amountReceived.toStringAsFixed(0);
    selectedStatus.value = payment.paymentStatus;
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

    final member = selectedMember.value!;
    final payment = PaymentModel(
      id: editingPayment?.id,
      memberId: member['id'],
      memberName: member['name'],
      packageId: member['package_id'],
      packageName: member['package_name'],
      membershipMonth: selectedMonth.value,
      packageAmount: packageAmount.value,
      amountReceived: double.tryParse(amountReceivedController.text) ?? 0.0,
      paymentStatus: selectedStatus.value,
      paymentDate: paymentDateController.text.isNotEmpty
          ? paymentDateController.text
          : null,
    );

    try {
      isFormLoading.value = true;
      bool success;
      if (editingPayment != null) {
        success = await PaymentService.updatePayment(
          editingPayment!.id!,
          payment,
        );
      } else {
        success = await PaymentService.addPayment(payment);
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
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF5252),
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
    } catch (_) {}
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<String> get monthOptions {
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
    final now = DateTime.now();
    List<String> options = [];
    for (int i = -2; i <= 3; i++) {
      final date = DateTime(now.year, now.month + i);
      options.add('${months[date.month - 1]} ${date.year}');
    }
    return options;
  }
}

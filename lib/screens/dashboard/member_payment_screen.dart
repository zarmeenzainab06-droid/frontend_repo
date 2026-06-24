import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/member_layout.dart';
import 'package:image_picker/image_picker.dart';

class MemberPaymentScreen extends StatefulWidget {
  const MemberPaymentScreen({super.key});

  @override
  State<MemberPaymentScreen> createState() => _MemberPaymentScreenState();
}

class _MemberPaymentScreenState extends State<MemberPaymentScreen> {
  String _selectedMethod = 'online';
  String _selectedMonth = '';
  bool _isLoading = false;
  List<dynamic> _payments = [];
  bool _loadingPayments = true;
  final box = GetStorage();

  // Online payment fields
  final _transactionIdController = TextEditingController();
  String? _uploadedImageName;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Card payment fields
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final List<String> _months = [
    'January 2026',
    'February 2026',
    'March 2026',
    'April 2026',
    'May 2026',
    'June 2026',
    'July 2026',
    'August 2026',
    'September 2026',
    'October 2026',
    'November 2026',
    'December 2026',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = _months[DateTime.now().month - 1];
    _loadPayments();
  }

  String _getToken() => box.read('token') ?? '';

  // Load payment history from backend
  Future<void> _loadPayments() async {
    try {
      final response = await http.get(
        Uri.parse('http://gym.sandbox.pk/api/payments/my-payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _payments = data['payments'];
          _loadingPayments = false;
        });
      }
    } catch (e) {
      setState(() => _loadingPayments = false);
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _uploadedImageName = image.name;
      });
      Get.snackbar(
        'Success',
        'Screenshot selected!',
        backgroundColor: AppTheme.activeLight,
        colorText: AppTheme.active,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Submit payment to backend
  Future<void> _submitPayment() async {
    // Online validation
    if (_selectedMethod == 'online') {
      if (_transactionIdController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Transaction ID daalo',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_uploadedImageName == null) {
        Get.snackbar(
          'Error',
          'Payment screenshot upload karo',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Card validation
    if (_selectedMethod == 'card') {
      if (_cardNumberController.text.isEmpty ||
          _cardHolderController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Sab card fields fill karo',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://gym.sandbox.pk/api/payments/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
        body: jsonEncode({
          'amount': 2000,
          'method': _selectedMethod,
          'month': _selectedMonth,
          'transaction_id': _transactionIdController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Payment submit ho gayi! Admin approval ka wait karo.',
          backgroundColor: AppTheme.activeLight,
          colorText: AppTheme.active,
          snackPosition: SnackPosition.BOTTOM,
        );
        _clearFields();
        _loadPayments();
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Error hua',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection error',
        backgroundColor: AppTheme.expiredLight,
        colorText: AppTheme.expired,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    setState(() => _isLoading = false);
  }

  // Clear all form fields
  void _clearFields() {
    _transactionIdController.clear();
    _cardNumberController.clear();
    _cardHolderController.clear();
    _expiryController.clear();
    _cvvController.clear();
    setState(() {
      _uploadedImageName = null;
      _selectedImage = null;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return AppTheme.active;
      case 'pending':
        return AppTheme.pending;
      case 'failed':
        return AppTheme.expired;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _statusLightColor(String status) {
    switch (status) {
      case 'paid':
        return AppTheme.activeLight;
      case 'pending':
        return AppTheme.pendingLight;
      case 'failed':
        return AppTheme.expiredLight;
      default:
        return AppTheme.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemberLayout(
      currentIndex: 2,
      title: 'Member Portal',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make Payment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Payment form card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [AppTheme.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month dropdown
                  const Text(
                    'Select Month',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _months.map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedMonth = val!),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment method selection
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Online button
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedMethod = 'online'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedMethod == 'online'
                                  ? AppTheme.primaryLight
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedMethod == 'online'
                                    ? AppTheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.phone_android,
                                  color: _selectedMethod == 'online'
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Online',
                                  style: TextStyle(
                                    color: _selectedMethod == 'online'
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card button
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedMethod = 'card'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedMethod == 'card'
                                  ? AppTheme.primaryLight
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedMethod == 'card'
                                    ? AppTheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: _selectedMethod == 'card'
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Card',
                                  style: TextStyle(
                                    color: _selectedMethod == 'card'
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Online payment fields
                  if (_selectedMethod == 'online') ...[
                    // Upload screenshot button
                    const Text(
                      'Upload Payment Screenshot',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickImage, // Pick image from gallery
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _uploadedImageName != null
                              ? AppTheme.activeLight
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _uploadedImageName != null
                                ? AppTheme.active
                                : AppTheme.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _uploadedImageName != null
                                  ? Icons.check_circle
                                  : Icons.upload_file,
                              color: _uploadedImageName != null
                                  ? AppTheme.active
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _uploadedImageName ??
                                    'Click to upload screenshot',
                                style: TextStyle(
                                  color: _uploadedImageName != null
                                      ? AppTheme.active
                                      : AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Show selected image preview
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _selectedImage!.path,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: AppTheme.primary,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Image selected',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Transaction ID field
                    const Text(
                      'Transaction ID',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _transactionIdController,
                      hint: 'Transaction ID enter karo',
                      icon: Icons.tag,
                    ),
                  ],

                  // Card payment fields
                  if (_selectedMethod == 'card') ...[
                    const Text(
                      'Card Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _cardNumberController,
                      hint: '1234 5678 9012 3456',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Card Holder Name',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _cardHolderController,
                      hint: 'Name on card',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Expiry date field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Expiry Date',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: _expiryController,
                                hint: 'MM/YY',
                                icon: Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // CVV field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CVV',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildField(
                                controller: _cvvController,
                                hint: '***',
                                icon: Icons.lock_outline,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Submit payment button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // View payment history button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Get.to(() => const MemberPaymentHistoryScreen()),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.history, color: AppTheme.primary),
                label: const Text(
                  'View Payment History',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

// Payment History Screen
class MemberPaymentHistoryScreen extends StatefulWidget {
  const MemberPaymentHistoryScreen({super.key});

  @override
  State<MemberPaymentHistoryScreen> createState() =>
      _MemberPaymentHistoryScreenState();
}

class _MemberPaymentHistoryScreenState
    extends State<MemberPaymentHistoryScreen> {
  List<dynamic> _payments = [];
  bool _isLoading = true;
  final box = GetStorage();

  String _getToken() => box.read('token') ?? '';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  // Load all payments from backend
  Future<void> _loadPayments() async {
    try {
      final response = await http.get(
        Uri.parse('http://gym.sandbox.pk/api/payments/my-payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_getToken()}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _payments = data['payments'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return AppTheme.active;
      case 'pending':
        return AppTheme.pending;
      case 'failed':
        return AppTheme.expired;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _statusLightColor(String status) {
    switch (status) {
      case 'paid':
        return AppTheme.activeLight;
      case 'pending':
        return AppTheme.pendingLight;
      case 'failed':
        return AppTheme.expiredLight;
      default:
        return AppTheme.background;
    }
  }

  // Calculate total paid amount
  double get _totalPaid => _payments
      .where((p) => p['status'] == 'paid')
      .fold(0.0, (sum, p) => sum + double.parse(p['amount'].toString()));

  // Count pending payments
  int get _pendingCount =>
      _payments.where((p) => p['status'] == 'pending').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Payment History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary cards row
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          'Total Paid',
                          'Rs. ${_totalPaid.toStringAsFixed(0)}',
                          Icons.check_circle,
                          AppTheme.active,
                          AppTheme.activeLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          'Transactions',
                          '${_payments.length}',
                          Icons.receipt,
                          AppTheme.primary,
                          AppTheme.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          'Pending',
                          '$_pendingCount',
                          Icons.access_time,
                          AppTheme.pending,
                          AppTheme.pendingLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Payment list
                  _payments.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Koi payment nahi mili',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : Column(
                          children: _payments.map((payment) {
                            final status = payment['status'] ?? 'pending';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [AppTheme.cardShadow],
                              ),
                              child: Row(
                                children: [
                                  // Status icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _statusLightColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      status == 'paid'
                                          ? Icons.check_circle
                                          : status == 'pending'
                                          ? Icons.access_time
                                          : Icons.cancel,
                                      color: _statusColor(status),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Payment details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment['month'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          payment['method']?.toUpperCase() ??
                                              '',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Amount and status badge
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rs. ${payment['amount']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusLightColor(status),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: _statusColor(status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  // Summary card widget
  Widget _summaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

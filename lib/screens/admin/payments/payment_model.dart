// lib/screens/admin/payments/payment_model.dart

class PaymentModel {
  final int? id;
  final int memberId;
  final String memberName;
  final int? packageId;
  final String packageName;
  final String membershipMonth;
  final double packageAmount;
  final double amountReceived;
  final String paymentStatus; // 'Paid' | 'Partial' | 'Unpaid'
  final String? paymentDate;
  final String? createdAt;

  PaymentModel({
    this.id,
    required this.memberId,
    required this.memberName,
    this.packageId, // ← make nullable
    required this.packageName,
    required this.membershipMonth,
    required this.packageAmount,
    required this.amountReceived,
    required this.paymentStatus,
    this.paymentDate,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int?,
      memberId: (json['user_id'] ?? json['member_id'] ?? 0) as int,
      memberName: json['member_name']?.toString() ?? '',
      packageId: json['package_id'] as int?,
      packageName: json['package_name']?.toString() ?? '',
      membershipMonth: json['membership_month']?.toString() ?? '',
      packageAmount:
          double.tryParse(json['package_amount']?.toString() ?? '0') ?? 0.0,
      amountReceived:
          double.tryParse(json['amount_received']?.toString() ?? '0') ?? 0.0,
      // ← capitalize first letter so 'paid' → 'Paid' for UI filters
      paymentStatus: _capitalize(
        json['payment_status']?.toString() ??
            json['status']?.toString() ??
            'Unpaid',
      ),
      paymentDate: json['payment_date']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  // add this static helper inside the class
  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
  Map<String, dynamic> toJson() {
    return {
      'user_id': memberId,
      'package_id': packageId,
      'membership_month': membershipMonth,
      'package_amount': packageAmount,
      'amount_received': amountReceived,
      'status': paymentStatus.toLowerCase(), // ← backend expects lowercase
      'payment_date': paymentDate,
    };
  }
}

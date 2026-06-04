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
      id: json['id'],
      memberId: json['user_id'] ?? json['member_id'], // ← handle both keys
      memberName: json['member_name'] ?? '',
      packageId: json['package_id'], // ← nullable, no crash
      packageName: json['package_name'] ?? '',
      membershipMonth: json['membership_month'] ?? '',
      packageAmount: double.tryParse(json['package_amount'].toString()) ?? 0.0,
      amountReceived:
          double.tryParse(json['amount_received'].toString()) ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'Unpaid',
      paymentDate: json['payment_date'],
      createdAt: json['created_at'],
    );
  }

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

// lib/models/member_model.dart

class MemberModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String trainerName;
  final String currentPlan;
  final String memberSince;

  MemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.trainerName,
    required this.currentPlan,
    required this.memberSince,
  });

  // Backend se aaya JSON → Flutter Object
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      trainerName: json['trainer_name'] ?? 'Not Assigned',
      currentPlan: json['plan_name'] ?? 'No Plan',
      memberSince: json['member_since'] ?? '',
    );
  }
}

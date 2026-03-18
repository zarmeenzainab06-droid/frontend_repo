class User {
  final int id;
  final String fullName;
  final String email;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final bool isDiabetic;
  final bool hasHighBp;
  final String? createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.age,
    this.weight,
    this.height,
    this.gender,
    required this.isDiabetic,
    required this.hasHighBp,
    this.createdAt,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      age: json['age'],
      weight: json['weight'] != null
          ? double.parse(json['weight'].toString())
          : null,
      height: json['height'] != null
          ? double.parse(json['height'].toString())
          : null,
      gender: json['gender'],
      isDiabetic: json['is_diabetic'] == 1 || json['is_diabetic'] == true,
      hasHighBp: json['has_high_bp'] == 1 || json['has_high_bp'] == true,
      createdAt: json['created_at'],
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'is_diabetic': isDiabetic,
      'has_high_bp': hasHighBp,
      'created_at': createdAt,
    };
  }
}

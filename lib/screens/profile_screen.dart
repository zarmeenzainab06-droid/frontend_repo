import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/auth_service.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final box = GetStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  double bmi = 0.0;
  String bmiStatus = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Get user data from storage
    final user = box.read('user');

    if (user != null) {
      setState(() {
        userData = Map<String, dynamic>.from(user);
        _calculateBMI();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateBMI() {
    if (userData != null &&
        userData!['weight'] != null &&
        userData!['height'] != null) {
      double weight = double.parse(userData!['weight'].toString());
      double height =
          double.parse(userData!['height'].toString()) / 100; // cm to m

      bmi = weight / (height * height);

      if (bmi < 18.5) {
        bmiStatus = 'Underweight';
      } else if (bmi < 25) {
        bmiStatus = 'Normal';
      } else if (bmi < 30) {
        bmiStatus = 'Overweight';
      } else {
        bmiStatus = 'Obese';
      }
    }
  }

  void _logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey.shade700,
      onConfirm: () {
        AuthService.logout();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF5DB075)));
    }

    if (userData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey),
            SizedBox(height: 15),
            Text('Failed to load profile data'),
            SizedBox(height: 15),
            ElevatedButton(onPressed: _logout, child: Text('Go to Login')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Green Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              color: Color(0xFF5DB075),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Color(0xFF5DB075)),
                ),
                SizedBox(height: 15),
                Text(
                  userData!['name'] ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  userData!['email'] ?? '',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // BMI Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Body Mass Index (BMI)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        bmiStatus,
                        style: TextStyle(
                          fontSize: 16,
                          color: bmiStatus == 'Normal'
                              ? Color(0xFF5DB075)
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        Icons.monitor_weight,
                        'Weight',
                        '${userData!['weight'] ?? 0}',
                        'kilograms',
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        Icons.height,
                        'Height',
                        '${userData!['height'] ?? 0}',
                        'cm',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        Icons.cake,
                        'Age',
                        '${userData!['age'] ?? 0}',
                        'years old',
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        Icons.person,
                        'Gender',
                        userData!['gender'] ?? 'N/A',
                        '',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),

                // Health Conditions
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Conditions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildHealthCondition(
                        Icons.water_drop,
                        'Diabetic',
                        userData!['is_diabetic'] == 1 ||
                            userData!['is_diabetic'] == true,
                      ),
                      SizedBox(height: 10),
                      _buildHealthCondition(
                        Icons.favorite,
                        'Blood Pressure',
                        userData!['has_bp'] == 1 || userData!['has_bp'] == true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Edit profile feature will be available soon',
                        backgroundColor: Colors.white,
                        colorText: Colors.black87,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF5DB075), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5DB075),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    String unit,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF5DB075), size: 28),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthCondition(
    IconData icon,
    String condition,
    bool hasCondition,
  ) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF5DB075), size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            condition,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: hasCondition
                ? Colors.orange.shade100
                : Color(0xFF5DB075).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hasCondition ? 'Yes' : 'No',
            style: TextStyle(
              fontSize: 14,
              color: hasCondition ? Colors.orange.shade700 : Color(0xFF5DB075),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

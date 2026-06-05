import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/member_model.dart';
import '../../core/services/member_service.dart';
import '../../core/widgets/member_layout.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  MemberModel? _member;
  bool _isLoading = true;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final member = await MemberService.getMyProfile();
    setState(() {
      _member = member;
      _isLoading = false;
    });
  }

  String _getInitial() {
    if (_member == null || _member!.fullName.isEmpty) return '?';
    return _member!.fullName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return MemberLayout(
      currentIndex: 3, // ✅ Profile tab active
      title: 'Member Portal',
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            )
          : _member == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Profile load nahi hua',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('Backend connection check karo',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935)),
                        child: const Text('Retry',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Profile',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 16),

                        // Profile Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFFE53935),
                                child: Text(_getInitial(),
                                    style: const TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 12),
                              Text(_member!.fullName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text('Member since ${_member!.memberSince}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 20),
                              const Divider(
                                  height: 1, color: Color(0xFFEEEEEE)),
                              _buildInfoTile(
                                  icon: Icons.person_outline,
                                  label: 'Full Name',
                                  value: _member!.fullName),
                              _buildInfoTile(
                                  icon: Icons.email_outlined,
                                  label: 'Email Address',
                                  value: _member!.email),
                              _buildInfoTile(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone Number',
                                  value: _member!.phone),
                              _buildInfoTile(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Date of Birth',
                                  value: _member!.dateOfBirth),
                              _buildInfoTile(
                                  icon: Icons.fitness_center,
                                  label: 'Trainer',
                                  value: _member!.trainerName),
                              _buildInfoTile(
                                  icon: Icons.card_membership_outlined,
                                  label: 'Current Plan',
                                  value: _member!.currentPlan,
                                  isLast: true),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildActionTile(
                                label: 'Edit Profile',
                                icon: Icons.edit_outlined,
                                onTap: () =>
                                    Get.toNamed('/member-edit-profile'),
                              ),
                              const Divider(
                                  height: 1, indent: 16, endIndent: 16),
                              _buildActionTile(
                                label: 'Change Password',
                                icon: Icons.lock_outline,
                                onTap: () =>
                                    Get.toNamed('/member-change-password'),
                              ),
                              const Divider(
                                  height: 1, indent: 16, endIndent: 16),
                              _buildActionTile(
                                label: 'Payment History',
                                icon: Icons.receipt_long_outlined,
                                onTap: () =>
                                    Get.toNamed('/member-payment-history'),
                              ),
                              const Divider(
                                  height: 1, indent: 16, endIndent: 16),
                              _buildActionTile(
                                label: 'Logout',
                                icon: Icons.logout,
                                isLogout: true,
                                onTap: _showLogoutDialog,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Kya aap logout karna chahte hain?',
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE53935),
      onConfirm: () {
        box.erase();
        Get.offAllNamed('/login');
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Colors.blueGrey),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _buildActionTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: isLogout ? const Color(0xFFE53935) : Colors.blueGrey,
          size: 20),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              color: isLogout ? const Color(0xFFE53935) : Colors.black87,
              fontWeight: FontWeight.w500)),
      trailing: isLogout
          ? null
          : const Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
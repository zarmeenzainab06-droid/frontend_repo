import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/theme.dart';
import '../../core/services/member_service.dart';

class MemberChangePasswordScreen extends StatefulWidget {
  const MemberChangePasswordScreen({super.key});

  @override
  State<MemberChangePasswordScreen> createState() =>
      _MemberChangePasswordScreenState();
}

class _MemberChangePasswordScreenState
    extends State<MemberChangePasswordScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    if (_currentPassController.text.isEmpty ||
        _newPassController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      Get.snackbar('Error', 'Sab fields fill karo',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_newPassController.text != _confirmPassController.text) {
      Get.snackbar('Error', 'New password match nahi kar raha',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_newPassController.text.length < 6) {
      Get.snackbar('Error', 'Password kam az kam 6 characters ka hona chahiye',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);

    final result = await MemberService.changePassword(
      currentPassword: _currentPassController.text,
      newPassword: _newPassController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Get.snackbar('Success', 'Password change ho gaya!',
          backgroundColor: AppTheme.activeLight,
          colorText: AppTheme.active,
          snackPosition: SnackPosition.BOTTOM);
      Get.back();
    } else {
      Get.snackbar('Error', result['message'] ?? 'Error hua',
          backgroundColor: AppTheme.expiredLight,
          colorText: AppTheme.expired,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline,
                  size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),

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
                  _buildLabel('Current Password'),
                  _buildPasswordField(
                    controller: _currentPassController,
                    hint: 'Purana password likho',
                    obscure: _obscureCurrent,
                    onToggle: () => setState(
                        () => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('New Password'),
                  _buildPasswordField(
                    controller: _newPassController,
                    hint: 'Naya password likho',
                    obscure: _obscureNew,
                    onToggle: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Confirm New Password'),
                  _buildPasswordField(
                    controller: _confirmPassController,
                    hint: 'Naya password dobara likho',
                    obscure: _obscureConfirm,
                    onToggle: () => setState(
                        () => _obscureConfirm = !_obscureConfirm),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Change Password',
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
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary)),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint),
        prefixIcon: const Icon(Icons.lock_outline,
            color: AppTheme.textSecondary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
}
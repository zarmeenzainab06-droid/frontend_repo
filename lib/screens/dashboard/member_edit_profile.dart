import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/member_service.dart';

class MemberEditProfileScreen extends StatefulWidget {
  const MemberEditProfileScreen({super.key});

  @override
  State<MemberEditProfileScreen> createState() =>
      _MemberEditProfileScreenState();
}

class _MemberEditProfileScreenState extends State<MemberEditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _nameController.text = box.read('userName') ?? '';
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final member = await MemberService.getMyProfile();
    if (member != null) {
      _nameController.text = member.fullName;
      _phoneController.text = stripPakPhonePrefix(member.phone);
    }
    if (mounted) setState(() => _isLoadingProfile = false);
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;
    if (_nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Name required hai',
        backgroundColor: AppTheme.expiredLight,
        colorText: AppTheme.expired,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await MemberService.updateProfile(
      name: _nameController.text.trim(),
      phone: normalizePakPhone(_phoneController.text.trim()),
    );

    setState(() => _isLoading = false);

    if (success) {
      // Updated name save karo
      box.write('userName', _nameController.text.trim());

      Get.snackbar(
        'Success',
        'Profile update ho gaya!',
        backgroundColor: AppTheme.activeLight,
        colorText: AppTheme.active,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } else {
      Get.snackbar(
        'Error',
        'Update nahi hua, dobara try karo',
        backgroundColor: AppTheme.expiredLight,
        colorText: AppTheme.expired,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Edit Profile'),
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
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.person, size: 40, color: Colors.white),
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
                  _buildLabel('Full Name'),
                  _buildField(
                    controller: _nameController,
                    hint: 'Apna naam likho',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  _buildField(
                    controller: _phoneController,
                    hint: '3001234567',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    prefixText: '+92 ',
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
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
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        prefixText: prefixText,
        counterText: '',
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
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

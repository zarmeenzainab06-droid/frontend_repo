import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../core/utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        backgroundColor: AppTheme.expiredLight,
        colorText: AppTheme.expired,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.forgotPassword(email);
    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() => _emailSent = true);
    } else {
      Get.snackbar(
        'Error',
        result['message'] ?? 'Something went wrong',
        backgroundColor: AppTheme.expiredLight,
        colorText: AppTheme.expired,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ── Back button ──────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [AppTheme.cardShadow],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    boxShadow: [AppTheme.cardShadow],
                  ),
                  child: _emailSent ? _buildSuccessView() : _buildFormView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Center(
          child: Text(
            'Forgot Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Enter your email and we\'ll send you\na link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 28),

        const Text(
          'Email Address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'your.email@gmail.com',
            hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Send Reset Link',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.green,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        const Text(
          'The link expires in 1 hour.',
          style: TextStyle(fontSize: 12, color: AppTheme.textHint),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            setState(() {
              _emailSent = false;
              _emailController.clear();
            });
          },
          child: const Text(
            'Try a different email',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

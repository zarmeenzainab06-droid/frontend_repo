import 'package:flutter/material.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/app_shell.dart';

class AdminCheckInScreen extends StatefulWidget {
  const AdminCheckInScreen({Key? key}) : super(key: key);

  @override
  State<AdminCheckInScreen> createState() => _AdminCheckInScreenState();
}

class _AdminCheckInScreenState extends State<AdminCheckInScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool? _checkedInSuccessfully;
  String _memberName = '';
  String _statusMessage = '';

  Future<void> _submitCheckIn() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter member ID, Phone, or Email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _checkedInSuccessfully = null;
      _memberName = '';
      _statusMessage = '';
    });

    try {
      final result = await AdminService.checkInMember(query);
      if (result['success']) {
        setState(() {
          _checkedInSuccessfully = true;
          _memberName = result['memberName'] ?? '';
          _statusMessage = result['message'] ?? 'Access Granted';
        });
      } else {
        setState(() {
          _checkedInSuccessfully = false;
          _memberName = result['memberName'] ?? '';
          _statusMessage = result['reason'] ?? 'Access Denied';
        });
      }
    } catch (e) {
      setState(() {
        _checkedInSuccessfully = false;
        _statusMessage = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: 'admin',
      subtitle: 'Gate Check-In',
      bottomNav: const AdminBottomNav(activeIndex: -1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RECEPTION TERMINAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                side: BorderSide(color: AppTheme.border),
              ),
              color: AppTheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Member',
                        hintText: 'Enter Member ID, Phone, or Email',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _submitCheckIn(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Verify & Log Check-In',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_checkedInSuccessfully != null) ...[
              const Text(
                'CHECK-IN STATUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _checkedInSuccessfully!
                      ? AppTheme.activeLight
                      : AppTheme.expiredLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: _checkedInSuccessfully!
                        ? AppTheme.active.withOpacity(0.3)
                        : AppTheme.expired.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _checkedInSuccessfully!
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 64,
                      color: _checkedInSuccessfully!
                          ? AppTheme.active
                          : AppTheme.expired,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _checkedInSuccessfully! ? 'ACCESS GRANTED' : 'ACCESS DENIED',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: _checkedInSuccessfully!
                            ? AppTheme.active
                            : AppTheme.expired,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_memberName.isNotEmpty) ...[
                      Text(
                        _memberName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

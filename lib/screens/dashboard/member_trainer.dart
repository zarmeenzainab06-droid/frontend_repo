import 'package:flutter/material.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/member_layout.dart';
import '../../core/services/member_service.dart';

class MemberTrainerScreen extends StatefulWidget {
  const MemberTrainerScreen({super.key});

  @override
  State<MemberTrainerScreen> createState() => _MemberTrainerScreenState();
}

class _MemberTrainerScreenState extends State<MemberTrainerScreen> {
  Map<String, dynamic>? _trainer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainer();
  }

  Future<void> _loadTrainer() async {
    setState(() => _isLoading = true);
    final data = await MemberService.getTrainer();
    setState(() {
      _trainer = data;
      _isLoading = false;
    });
  }

  String _getInitial() {
    if (_trainer == null || _trainer!['name'] == null) return '?';
    return _trainer!['name'][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return MemberLayout(
      currentIndex: 3,
      title: 'Member Portal',
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            )
          : _trainer == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Data load nahi hua'),
                  ElevatedButton(
                    onPressed: _loadTrainer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Trainer Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            _getInitial(),
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _trainer!['name'] ?? 'Not Assigned',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your Personal Trainer',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trainer Details
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTile(
                          Icons.person_outline,
                          'Full Name',
                          _trainer!['name'] ?? 'N/A',
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          Icons.email_outlined,
                          'Email',
                          _trainer!['email'] ?? 'N/A',
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          Icons.phone_outlined,
                          'Phone',
                          _trainer!['phone'] ?? 'N/A',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE53935)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

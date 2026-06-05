import 'package:flutter/material.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  int _currentIndex = 3; // Profile selected by default

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/member-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/member-membership');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/member-trainer');
        break;
      case 3:
        // Already on profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A1A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Row(
          children: [
            const Icon(Icons.fitness_center, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'GymFitex',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Member Portal',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF8B1A1A),
                      child: Text(
                        'J',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'John Smith',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Member since Jan 2026',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildInfoTile(icon: Icons.person_outline, label: 'Full Name', value: 'John Smith'),
                    _buildInfoTile(icon: Icons.email_outlined, label: 'Email Address', value: 'john@example.com'),
                    _buildInfoTile(icon: Icons.phone_outlined, label: 'Phone Number', value: '+1 234 567 8901'),
                    _buildInfoTile(icon: Icons.calendar_today_outlined, label: 'Date of Birth', value: 'March 15, 1995'),
                    _buildInfoTile(icon: Icons.fitness_center, label: 'Trainer', value: 'Mike Johnson'),
                    _buildInfoTile(icon: Icons.card_membership_outlined, label: 'Current Plan', value: 'Premium (6 Months)', isLast: true),
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      label: 'Edit Profile',
                      icon: Icons.edit_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, '/member-edit-profile');
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildActionTile(
                      label: 'Change Password',
                      icon: Icons.lock_outline,
                      onTap: () {
                        Navigator.pushNamed(context, '/member-change-password');
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildActionTile(
                      label: 'Payment History',
                      icon: Icons.receipt_long_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, '/member-payment-history');
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildActionTile(
                      label: 'Logout',
                      icon: Icons.logout,
                      isLogout: true,
                      onTap: () {
                        _showLogoutDialog();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ✅ Clickable Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8B1A1A),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership_outlined),
            activeIcon: Icon(Icons.card_membership),
            label: 'Membership',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Trainer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ✅ Logout Confirmation Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Kya aap logout karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFF8B1A1A))),
          ),
        ],
      ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
                ],
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
      leading: Icon(
        icon,
        color: isLogout ? const Color(0xFF8B1A1A) : Colors.blueGrey,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: isLogout ? const Color(0xFF8B1A1A) : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
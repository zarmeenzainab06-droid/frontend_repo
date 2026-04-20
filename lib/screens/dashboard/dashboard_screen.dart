import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_screen.dart';
import '../add_meal_screen.dart';
import '../diet_plan_screen.dart';
import '../profile_screen.dart';
import '../members/add_members.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];

  final List<Widget> _screens = [
    HomeScreen(),
    AddMealScreen(),
    AddMemberPage(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      // Scroll to top if same tab tapped
      _scrollControllers[index].animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, // ✅ just pass screens directly
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF5DB075),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Meal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Add Members',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

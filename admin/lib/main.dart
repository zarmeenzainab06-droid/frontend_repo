import 'package:flutter/material.dart';

void main() {
  runApp(SwiftGymApp());
}

class SwiftGymApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 3; // Profile default

  final screens = [
    Center(child: Text("Home Screen")),
    Center(child: Text("Members Screen")),
    Center(child: Text("Reports Screen")),
    AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      /// Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: "Members"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: "Reports"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

/// ================= PROFILE SCREEN =================
class AdminProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),

      /// TOP BAR
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Row(
          children: [
            Text("GymSwift",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Text("| Admin Panel"),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(Icons.person_outline),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// TITLE
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Admin Profile",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            /// CARD
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Column(
                children: [

                  /// PROFILE
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.red,
                    child: Text("A",
                        style:
                            TextStyle(fontSize: 28, color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  Text("Admin User",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("Administrator",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),

                  SizedBox(height: 20),
                  Divider(),

                  /// INFO
                  buildItem(Icons.person, "Full Name", "Admin User"),
                  buildItem(Icons.email, "Email Address", "admin@gym.com"),
                  buildItem(Icons.phone, "Phone Number", "+1 234 567 890"),
                  buildItem(Icons.location_on, "Gym Location",
                      "GymSwift Downtown Branch"),

                  Divider(),

                  /// ACTIONS
                  ListTile(
                    title: Text("Edit Profile"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    title: Text("Change Password"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),

                  /// LOGOUT
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text("Logout",
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Logout"),
                          content: Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Logged out")),
                                  );
                                },
                                child: Text("Logout",
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey)),
                Text(value,
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
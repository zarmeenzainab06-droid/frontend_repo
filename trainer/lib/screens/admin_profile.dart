import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),

      /// TOP BAR
      appBar: AppBar(
        backgroundColor: Color(0xFFD32F2F),
        elevation: 0,
        title: Row(
          children: [
            Text("GymSwift",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Text("| Admin Panel",
                style: TextStyle(fontWeight: FontWeight.w400)),
          ],
        ),
      ),

      body: Center(
        child: Container(
          width: 700, // web feel
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 1,
              )
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              /// TITLE
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Admin Profile",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),

              SizedBox(height: 30),

              /// PROFILE CENTER
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFFD32F2F),
                    child: Text(
                      "A",
                      style: TextStyle(
                          fontSize: 32, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Admin User",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
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
                ],
              ),

              SizedBox(height: 30),

              Divider(),

              SizedBox(height: 20),

              /// LEFT DETAILS (Aligned like web)
              Column(
                children: [

                  buildRow(Icons.person, "Full Name", "Admin User"),
                  buildRow(Icons.email, "Email Address", "admin@gym.com"),
                  buildRow(Icons.phone, "Phone Number", "+1 234 567 890"),
                  buildRow(Icons.location_on, "Gym Location",
                      "GymSwift Downtown Branch"),
                ],
              ),

              SizedBox(height: 30),

              Divider(),

              SizedBox(height: 20),

              /// ACTIONS
              Column(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text("Edit Profile"),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("Change Password"),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("Logout",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// REUSABLE ROW (pixel spacing)
  Widget buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          SizedBox(width: 15),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
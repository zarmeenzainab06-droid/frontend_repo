import 'package:flutter/material.dart';

void main() {
  runApp(SwiftGymApp());
}

class SwiftGymApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  int currentIndex = 0;

  List<Map<String, String>> data = [
    {
      "title": "Welcome to Swift Gym",
      "desc": "Apni fitness journey aaj se start karein",
      "icon": "fitness_center"
    },
    {
      "title": "Track Your Progress",
      "desc": "Workout aur weight ko monitor karein",
      "icon": "show_chart"
    },
    {
      "title": "Manage Schedule",
      "desc": "Apni gym timing aur sessions plan karein",
      "icon": "calendar_today"
    },
    {
      "title": "Expert Trainers",
      "desc": "Professional trainers se guidance hasil karein",
      "icon": "person"
    },
    {
      "title": "Let’s Get Started",
      "desc": "Login ya signup karke start karein",
      "icon": "check_circle"
    },
  ];

  IconData getIcon(String name) {
    switch (name) {
      case "fitness_center":
        return Icons.fitness_center;
      case "show_chart":
        return Icons.show_chart;
      case "calendar_today":
        return Icons.calendar_today;
      case "person":
        return Icons.person;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              _controller.jumpToPage(data.length - 1);
            },
            child: Text("Skip", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: data.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        getIcon(data[i]["icon"]!),
                        size: 120,
                        color: Colors.red,
                      ),
                      SizedBox(height: 30),
                      Text(
                        data[i]["title"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      Text(
                        data[i]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              data.length,
              (index) => Container(
                margin: EdgeInsets.all(4),
                width: currentIndex == index ? 12 : 8,
                height: currentIndex == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.red
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          /// Buttons
          Padding(
            padding: EdgeInsets.all(20),
            child: currentIndex == data.length - 1
                ? Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          print("Sign Up clicked");
                        },
                        child: Text("Sign Up"),
                      ),
                      SizedBox(height: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          print("Login clicked");
                        },
                        child: Text("Login",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text("Next"),
                  ),
          )
        ],
      ),
    );
  }
}
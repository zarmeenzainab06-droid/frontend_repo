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
      "title": "Swift Gym",
      "desc": "Welcome! Apni fitness journey start karein",
    },
    {
      "title": "Swift Gym - Track Progress",
      "desc": "Apni workout aur body progress ko track karein",
    },
    {
      "title": "Swift Gym - Schedule",
      "desc": "Daily workout aur sessions manage karein",
    },
    {
      "title": "Swift Gym - Trainers",
      "desc": "Expert trainers se training hasil karein",
    },
    {
      "title": "Swift Gym",
      "desc": "Login ya Signup karke start karein",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// Skip Button
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
          /// Pages
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
                      Icon(Icons.fitness_center,
                          size: 120, color: Colors.red),
                      SizedBox(height: 30),

                      /// Title
                      Text(
                        data[i]["title"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),

                      SizedBox(height: 15),

                      /// Description
                      Text(
                        data[i]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
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
                          print("Signup Clicked");
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
                          print("Login Clicked");
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
          ),
        ],
      ),
    );
  }
}
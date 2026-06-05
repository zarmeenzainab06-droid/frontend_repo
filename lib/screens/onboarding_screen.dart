import 'package:flutter/material.dart';
<<<<<<< HEAD

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
=======
import '../routes/app_routes.dart';
>>>>>>> 86a3079d988721b94096cf26432b44f45795e600

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> screens = [
    {
      "title": "Swift Gym",
      "desc": "Transform your body & mind with us",
      "img": "🏋️"
    },
    {
      "title": "Track Progress",
      "desc": "Monitor workouts and stay consistent",
      "img": "📊"
    },
    {
      "title": "Workout Plans",
      "desc": "Get personalized fitness plans",
      "img": "📅"
    },
    {
      "title": "Expert Trainers",
      "desc": "Train with professionals بسهولة",
      "img": "👨‍🏫"
    },
    {
      "title": "Get Started",
      "desc": "Login or Sign up to begin",
      "img": "🚀"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// Skip
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              _controller.jumpToPage(screens.length - 1);
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
              itemCount: screens.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// BIG ICON CARD (like design)
                      Container(
                        height: 220,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            screens[i]["img"]!,
                            style: TextStyle(fontSize: 80),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      /// TITLE
                      Text(
                        screens[i]["title"]!,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),

                      SizedBox(height: 15),

                      /// DESC
                      Text(
                        screens[i]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              screens.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.all(4),
                width: currentIndex == index ? 14 : 8,
                height: currentIndex == index ? 14 : 8,
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

          /// BUTTONS
          Padding(
            padding: const EdgeInsets.all(20),
            child: currentIndex == screens.length - 1
                ? Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {},
                        child: Text("Sign Up"),
                      ),
                      SizedBox(height: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 55),
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {},
                        child: Text("Login",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
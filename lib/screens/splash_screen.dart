import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller; // varibale duration of animation
  late final Animation<double> _scale; // 1.0 lgo zom
  late final Animation<double> _fade; // opacty of logo and text

  static const _primary = Color(0xFFE53935); // varible

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward(); // Start the animation immediately

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    // Navigation logic (unchanged)
    Future.delayed(const Duration(seconds: 3), () {
      // Delay for 3 seconds before navigating
      final box = GetStorage();
      final token = box.read('token');
      final role = box.read('role');

      if (token != null) {
        if (role == 'admin') {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else if (role == 'trainer') {
          Get.offAllNamed(AppRoutes.trainerDashboard);
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fade,
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Gym",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: "Fitex",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _fade,
              child: const Text(
                "Smart Gym Management",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fade,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

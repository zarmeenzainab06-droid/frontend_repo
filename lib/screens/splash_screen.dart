import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _logoScaleController;
  late AnimationController _logoGlowController;
  late AnimationController _textFadeController;
  late AnimationController _dotsController;
  late AnimationController _bgCircleController;

  // --- Animations ---
  late Animation<double> _logoScale;
  late Animation<double> _logoGlow;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _bgCircleScale;

  @override
  void initState() {
    super.initState();

    // Background circle pulse
    _bgCircleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _bgCircleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgCircleController, curve: Curves.easeOut),
    );

    // Logo scale-in with bounce
    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoScaleController, curve: Curves.elasticOut),
    );

    // Logo icon glow pulse (looping)
    _logoGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _logoGlowController, curve: Curves.easeInOut),
    );

    // App name fade + slide
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
        );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
          CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
        );

    // Dots bounce
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Sequence the animations
    _bgCircleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoScaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textFadeController.forward();
    });

    // Navigation logic (unchanged)
    Timer(const Duration(seconds: 3), () {
      final box = GetStorage();
      final token = box.read('token');
      final role = box.read('role');

      if (token != null) {
        if (role == 'admin') {
          Get.offAllNamed(AppRoutes.adminDashboard);
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
    _logoScaleController.dispose();
    _logoGlowController.dispose();
    _textFadeController.dispose();
    _dotsController.dispose();
    _bgCircleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle background circle expanding from center
          Center(
            child: AnimatedBuilder(
              animation: _bgCircleScale,
              builder: (_, __) => Transform.scale(
                scale: _bgCircleScale.value,
                child: Container(
                  width: size.width * 1.5,
                  height: size.width * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935).withOpacity(0.04),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo box with glow
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoScaleController,
                    _logoGlowController,
                  ]),
                  builder: (_, __) => Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.45),
                            blurRadius: _logoGlow.value + 10,
                            spreadRadius: _logoGlow.value * 0.4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App name
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
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
                              color: Color(0xFFE53935),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                FadeTransition(
                  opacity: _subtitleFade,
                  child: SlideTransition(
                    position: _subtitleSlide,
                    child: const Text(
                      "Smart Gym Management",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated dots at bottom
          Positioned(
            bottom: 55,
            left: 0,
            right: 0,
            child: _AnimatedDots(controller: _dotsController),
          ),
        ],
      ),
    );
  }
}

/// Three bouncing dots indicator
class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final delay = i * 0.18;
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final t = (controller.value - delay).clamp(0.0, 1.0);
            final offset = math.sin(t * math.pi) * 5.0;
            return Transform.translate(
              offset: Offset(0, -offset),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0
                      ? const Color(0xFFE53935)
                      : Colors.grey.shade300,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

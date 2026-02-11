import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF6dc57d);
    final accentColor = const Color(0xFFFF8A65);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF151d16)
          : const Color(0xFFf6f8f6),
      body: Stack(
        children: [
          // Background decorations
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.05 : 0.03,
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 40,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.rice_bowl,
                        size: 60,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.25,
                    right: 32,
                    child: Transform.rotate(
                      angle: 0.78,
                      child: Icon(Icons.grass, size: 80, color: primaryColor),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.25,
                    left: 24,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(Icons.eco, size: 70, color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 224,
                        height: 224,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF27272a)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF27272a)
                                : Colors.white,
                            width: 6,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: -16,
                                right: -16,
                                child: Icon(
                                  Icons.eco,
                                  size: 100,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                    Positioned(
                                      top: -4,
                                      right: -8,
                                      child: Icon(
                                        Icons.spa,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Healthy Wealthy',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF131613),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diet Planner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Eat Local, Live Healthy',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark
                          ? Colors.grey[400]
                          : const Color(0xFF4a5a4a),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 64),
                  // Progress bar
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF27272a)
                                      : primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 200 * _progressAnimation.value,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'LOADING...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            color: primaryColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 14,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tailored for Pakistani Cuisine',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

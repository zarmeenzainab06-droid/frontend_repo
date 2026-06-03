import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard/member_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_members_screen.dart';
import '../screens/members/add_member_screen.dart';
import '../screens/admin/admin_packages_screen.dart';
import '../screens/members/edit_member_screen.dart';
import '../screens/trainer/trainer_dashboard.dart';
import '../screens/trainer/trainer_members_screen.dart';
import '../screens/trainer/trainer_profile_screen.dart';
import '../screens/trainer/trainer_member_profile_screen.dart';
import '../screens/trainer/trainer_schedule_screen.dart';
import '../routes/auth_middleware.dart';

class AppRoutes {
  // ── Existing routes ──────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminMembers = '/admin/members';
  static const String adminPackages = '/admin/packages';
  static const String addMembers = '/add_members';
  static const String editMember = '/edit_member';

  // ── Trainer routes ───────────────────────────────────────────
  static const String trainerDashboard = '/trainer-dashboard';
  static const String trainerMembers = '/trainer/members';
  static const String trainerProfile = '/trainer/profile';
  static const String trainerMemberProfile = '/trainer/member-profile';
  static const String trainerSchedule = '/trainer/schedule';

  static final List<GetPage<dynamic>> pages = [
    // ── Public ──────────────────────────────────────────────────
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),

    // ── Member ──────────────────────────────────────────────────
    GetPage(
      name: dashboard,
      page: () => MemberDashboard(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Admin ────────────────────────────────────────────────────
    GetPage(
      name: adminDashboard,
      page: () => AdminDashboard(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: adminMembers,
      page: () => AdminMembersScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: adminPackages,
      page: () => AdminPackagesScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: addMembers,
      page: () => AddMemberPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editMember,
      page: () => EditMemberPage(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Trainer ──────────────────────────────────────────────────
    GetPage(
      name: trainerDashboard,
      page: () => TrainerDashboard(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: trainerMembers,
      page: () => TrainerMembersScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: trainerProfile,
      page: () => TrainerProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: trainerMemberProfile,
      page: () => TrainerMemberProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: trainerSchedule,
      page: () => TrainerScheduleScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

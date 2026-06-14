import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:third_task/screens/admin/payments/payment_model.dart'
    hide ManagePaymentsScreen;
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard/member_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_members_screen.dart';
import '../screens/admin/admin_packages_screen.dart';
import '../screens/admin/member_form_page.dart';
import '../routes/auth_middleware.dart';
import '../screens/admin/admin_trainers_screen.dart';
import '../screens/admin/admin_profile/admin_profile_screen.dart';
import '../screens/admin/payments/manage_payments_screen.dart';
import '../screens/admin/admin_slots_screen.dart';

// nimra
import '../screens/dashboard/member_profile.dart';
import '../screens/dashboard/member_membership.dart';
import '../screens/dashboard/member_trainer.dart';

// eman
import '../screens/trainer/trainer_dashboard.dart';
import '../screens/trainer/trainer_members_screen.dart';
import '../screens/trainer/trainer_profile_screen.dart';
import '../screens/trainer/trainer_member_profile_screen.dart';
import '../screens/trainer/trainer_schedule_screen.dart';

// routess
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminMembers = '/admin/members';
  static const String adminPackages = '/admin/packages'; // for packges
  static const String addMembers = '/add_members';
  static const String adminTrainers = '/admin/trainers'; // for the trainerss
  static const String adminProfile = '/admin/profile'; // for the profile
  static const String adminPayments = '/admin/payments'; // ← NEW
  static const String adminSlots = '/admin/slots'; // ← NEW

  // nimra
  static const String memberProfile = '/member_profile';
  static const String memberMembership = '/member_membership';
  static const String memberTrainer = '/member_trainer';

  //eman
  // ── Trainer routes ───────────────────────────────────────────
  static const String trainerDashboard = '/trainer-dashboard';
  static const String trainerMembers = '/trainer/members';
  static const String trainerProfile = '/trainer/profile';
  static const String trainerMemberProfile = '/trainer/member-profile';
  static const String trainerSchedule = '/trainer/schedule';

  // pages list
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(
      name: dashboard,
      page: () => MemberDashboard(),
      middlewares: [AuthMiddleware()],
    ),
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
      page: () => MemberFormPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: adminTrainers,
      page: () => const AdminTrainersScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: adminProfile,
      page: () => const AdminProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      // ← NEW
      name: adminPayments,
      page: () => const ManagePaymentsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Add to pages list
    GetPage(
      name: adminSlots,
      page: () => const AdminSlotsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // nimra
    // ── Member ──────────────────────────────────────────────────
    GetPage(name: memberProfile, page: () => MemberProfileScreen()),
    GetPage(name: memberMembership, page: () => MemberMembershipScreen()),
    GetPage(name: memberTrainer, page: () => MemberTrainerScreen()),
    GetPage(
      name: dashboard,
      page: () => MemberDashboard(),
      middlewares: [AuthMiddleware()],
    ),

    //member
    GetPage(
      name: memberProfile,
      page: () => MemberProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberMembership,
      page: () => MemberMembershipScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberTrainer,
      page: () => MemberTrainerScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberProfile,
      page: () => MemberProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberMembership,
      page: () => MemberMembershipScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberTrainer,
      page: () => MemberTrainerScreen(),
      middlewares: [AuthMiddleware()],
    ),

    //eman

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
    GetPage(
      name: memberProfile,
      page: () => MemberProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberMembership,
      page: () => MemberMembershipScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: memberTrainer,
      page: () => MemberTrainerScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

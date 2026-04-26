
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_members_screen.dart';
import '../screens/members/add_member_screen.dart';
import '../screens/members/edit_member_screen.dart';
import '../routes/auth_middleware.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminMembers = '/admin/members';
  static const String addMembers = '/add_members';
  static const String editMember = '/edit_member';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
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
      name: addMembers,
      page: () => AddMemberPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editMember,
      page: () => EditMemberPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

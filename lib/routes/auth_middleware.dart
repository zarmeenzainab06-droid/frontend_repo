import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage();
    final token = box.read('token');
    final role = box.read('role');

    // Not logged in go to login
    if (token == null) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Logged in but trying to access admin route without admin role
    if (route != null && route.startsWith('/admin') && role != 'admin') {
      return const RouteSettings(name: AppRoutes.dashboard);
      // i will add the other roles later like trainer and member tadaa
    }

    return null; // allow navigation
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/core/controller/session_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return SessionController.to.getLoginStatus()
        ? const RouteSettings(name: AppRoutes.dashboard)
        : const RouteSettings(name: AppRoutes.initial);
  }
}

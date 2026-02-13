import 'package:get/get.dart';
import 'package:swiftrun/common/routes/route.dart';
import 'package:swiftrun/core/controller/session_controller.dart';
import 'package:swiftrun/features/onboarding/view.dart';
import 'package:swiftrun/features/auth/index.dart';
import 'package:swiftrun/features/auth/presentation/atom/login/phoneNumberLogin.dart';
import 'package:swiftrun/features/booking/index.dart';
import 'package:swiftrun/features/booking/presentation/atoms/confirm_details/confirm_details.dart';
import 'package:swiftrun/features/booking/presentation/atoms/schedule_delivery/schedule.dart';
import 'package:swiftrun/features/dashboard/index.dart';
import 'package:swiftrun/features/messages/index.dart';
import 'package:swiftrun/features/payment/presentation/view.dart';
import 'package:swiftrun/features/profile/presentation/app_settings.dart';
import 'package:swiftrun/features/profile/presentation/help.dart';
import 'package:swiftrun/features/profile/presentation/payment_history.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.initial,
      page: () => SessionController.to.isLogin
          ? const DashboardScreen()
          : const OnBoardingScreen(),
      //middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.signin,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterName(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatScreen(),
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingScreen(),
    ),
    GetPage(
      name: AppRoutes.scheduleBooking,
      page: () => const BookingScreen(isInstant: false),
    ),
    GetPage(
      name: AppRoutes.deliveryDetails,
      page: () => DeliveryDetails(),
    ),
    GetPage(
      name: AppRoutes.confirmDetails,
      // page: () => const ConfirmDeliveryScreen(),
      page: () => const ConfirmDeliveryScreen(fromPage: 0),
    ),
    GetPage(
      name: AppRoutes.setProfilePic,
      page: () => const SetProfilePicture(),
    ),
    GetPage(
      name: AppRoutes.appSettings,
      page: () => const AppSettingScreen(),
    ),
    GetPage(
      name: AppRoutes.helpScreen,
      page: () => const HelpScreen(),
    ),
    GetPage(
      name: AppRoutes.faqScreen,
      page: () => const FaqScreen(),
    ),
    GetPage(
      name: AppRoutes.paymentHistory,
      page: () => const PaymentHistory(),
    ),
    GetPage(
      name: AppRoutes.paymentScreen,
      page: () => const PaymentMethodScreen(),
    ),
    GetPage(
      name: AppRoutes.scheduleDelivery,
      page: () => const ConfirmSchedule(),
    ),
  ];
}

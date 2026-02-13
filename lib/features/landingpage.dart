import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/widgets/custom_botton.dart';
import 'package:swiftrun/features/auth/presentation/atom/login/login.dart';
import 'package:swiftrun/features/auth/presentation/atom/register/name.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset('assets/images/swiftrunlogo.png'),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 70.h,
                bottom: 10.h,
              ),
              child: ButtonWidget(
                onTap: () => Get.to(() => const LoginScreen()),
                color: AppColor.primaryColor,
                widget: Text(
                  "Login",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColor.whiteColor),
                ),
              ),
            ),
            ButtonWidget(
              onTap: () => Get.to(() => const RegisterName()),
              // title: "Sign up manually",G
              color: AppColor.deepBlue,
              widget: Text(
                "Sign up manually",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColor.whiteColor),
              ),
            ),
            10.verticalSpace,
            ButtonWidget(
              onTap: () {},
              color: AppColor.disabledColor.withValues(alpha: 0.2),
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/google_icon.png"),
                  // FaIcon(FontAwesomeIcons.google),
                  15.horizontalSpace,
                  Text(
                    "Sign Up with Google",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColor.blackColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

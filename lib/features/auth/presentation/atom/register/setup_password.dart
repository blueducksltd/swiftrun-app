import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/widgets.dart';
import 'package:swiftrun/features/auth/presentation/controller.dart';
import 'package:swiftrun/features/auth/presentation/state.dart';

class SetupPasswordScreen extends StatefulWidget {
  const SetupPasswordScreen({super.key});

  @override
  State<SetupPasswordScreen> createState() => _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends State<SetupPasswordScreen> {
  final authController = Get.put(AuthenticationController());

  late FocusNode _password;

  @override
  void initState() {
    super.initState();
    _password = FocusNode();

    // Add listeners to update password matching status
    authController.authState.passwordController.addListener(_updatePasswordMatch);
    authController.authState.confirmPasswordController.addListener(_updatePasswordMatch);
  }

  // Simple method to check if passwords match
  void _updatePasswordMatch() {
    final password = authController.authState.passwordController.text;
    final confirmPassword = authController.authState.confirmPasswordController.text;

    authController.authState.isPasswordMatched.value =
        password.isNotEmpty &&
            confirmPassword.isNotEmpty &&
            password == confirmPassword &&
            password.length >= 6;
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    authController.authState.passwordController.removeListener(_updatePasswordMatch);
    authController.authState.confirmPasswordController.removeListener(_updatePasswordMatch);
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authstate = authController.authState;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: mainPaddingWidth,
            vertical: mainPaddingHeight,
          ),
          child: Form(
            key: authstate.passwordFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                60.verticalSpace,
                Text(
                  "Setup Password",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  "Please create a secure password for your account",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                30.verticalSpace,
                ...[
                  RoundTextField(
                    hitText: "Password",
                    obscureText: authstate.isObsecure.value,
                    controller: authstate.passwordController,
                    focusNode: _password,
                    rigtIcon: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 30,
                      child: IconButton(
                        onPressed: () {
                          setState(
                            () {
                              authstate.isObsecure.value =
                                  !authstate.isObsecure.value;
                            },
                          );
                        },
                        icon: Icon(
                          authstate.isObsecure.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return "Please enter a password";
                      }
                      if (p0.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  Obx(
                    () => RoundTextField(
                      hitText: "Confirm password",
                      obscureText: authstate.isObsecureConfirm.value,
                      controller: authstate.confirmPasswordController,
                      validator: (p0) {
                        if (p0 != authstate.passwordController.text) {
                          return "Password not matched";
                        }
                        return null;
                      },
                      rigtIcon: Container(
                        alignment: Alignment.center,
                        width: 20,
                        height: 30,
                        child: IconButton(
                          onPressed: () {
                            setState(
                              () {
                                authstate.isObsecureConfirm.value =
                                    !authstate.isObsecureConfirm.value;
                              },
                            );
                          },
                          icon: Icon(
                            authstate.isObsecureConfirm.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Must be at least 6 characters",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  )
                ].separate(10.h),
                150.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallButton(
                      onTap: () => Get.back(),
                      width: 40.h,
                      child: const Icon(
                        Icons.arrow_back,
                        size: 21,
                      ),
                    ),
                    Obx(
                      () => SmallButton(
                        onTap: authstate.isPasswordMatched.value
                            ? () {
                                if (authstate.passwordFormKey.currentState!
                                    .validate()) {
                                  authController.completeRegistration();
                                }
                              }
                            : () {
                                errorMethod("Password not matched");
                              },
                        width: 85.h,
                        isColor: true,
                        child: Text(
                          'Finish',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColor.whiteColor,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

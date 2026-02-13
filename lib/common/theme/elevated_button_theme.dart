import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class AppElevatedButtonTheme {
  AppElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColor.whiteColor,
      backgroundColor: AppColor.primaryColor,
      disabledForegroundColor: AppColor.disabledColor,
      disabledBackgroundColor: AppColor.disabledColor,
      side: BorderSide(color: AppColor.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: TextStyle(
          fontSize: 16.sp,
          color: AppColor.blackColor,
          fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColor.whiteColor,
      backgroundColor: AppColor.primaryColor,
      disabledForegroundColor: AppColor.disabledColor,
      disabledBackgroundColor: AppColor.disabledColor,
      side: BorderSide(color: AppColor.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: TextStyle(
          fontSize: 16.sp,
          color: AppColor.whiteColor,
          fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
  );
}

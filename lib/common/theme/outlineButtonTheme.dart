// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class AppOutlineButtonTheme {
  static OutlinedButtonThemeData lightOutlineButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColor.blackColor,
      side: BorderSide(color: AppColor.primaryColor),
      textStyle: TextStyle(
          fontSize: 16.sp,
          color: AppColor.blackColor,
          fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
    ),
  );

  static OutlinedButtonThemeData darkOutlineButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColor.whiteColor,
      side: BorderSide(color: AppColor.primaryColor),
      textStyle: TextStyle(
          fontSize: 16.sp,
          color: AppColor.whiteColor,
          fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
    ),
  );
}

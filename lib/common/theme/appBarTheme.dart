// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class TAppBarTheme {
  TAppBarTheme._();
  static AppBarTheme lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    iconTheme: IconThemeData(color: AppColor.blackColor, size: 24.sp),
    actionsIconTheme: IconThemeData(color: AppColor.blackColor, size: 24.sp),
    titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.blackColor),
  );

  static AppBarTheme darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    iconTheme: IconThemeData(color: AppColor.whiteColor, size: 24.sp),
    actionsIconTheme: IconThemeData(color: AppColor.whiteColor, size: 24.sp),
    titleTextStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.blackColor),
  );
}

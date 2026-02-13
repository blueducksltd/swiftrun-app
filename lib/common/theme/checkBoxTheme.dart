// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class AppCheckBoxTheme {
  AppCheckBoxTheme._();

  static CheckboxThemeData lightCheckBoxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    side: BorderSide.none,
    checkColor:
        WidgetStateProperty.resolveWith((states) => AppColor.whiteColor),
    fillColor: WidgetStateProperty.resolveWith(
      (states) => AppColor.primaryColor,
    ),
  );

  static CheckboxThemeData darkCheckBoxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    side: BorderSide.none,
    fillColor: WidgetStateProperty.resolveWith(
      (states) => AppColor.primaryColor,
    ),
  );
}

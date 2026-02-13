// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class AppTextFormFieldTheme {
  static InputDecorationTheme lightInputDecoration = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: AppColor.disabledColor,
    suffixIconColor: AppColor.disabledColor,
    labelStyle:
        const TextStyle().copyWith(fontSize: 14.sp, color: AppColor.blackColor),
    hintStyle:
        const TextStyle().copyWith(fontSize: 14.sp, color: AppColor.blackColor),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle()
        .copyWith(color: AppColor.blackColor.withValues(alpha: 0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.disabledColor),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.disabledColor),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.blackColor),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.errorColor),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
          width: 1, color: AppColor.errorColor.withValues(alpha: .5)),
    ),
  );

  static InputDecorationTheme darkInputDecoration = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: AppColor.disabledColor,
    suffixIconColor: AppColor.disabledColor,
    labelStyle:
        const TextStyle().copyWith(fontSize: 14.sp, color: AppColor.whiteColor),
    hintStyle:
        const TextStyle().copyWith(fontSize: 14.sp, color: AppColor.whiteColor),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle()
        .copyWith(color: AppColor.blackColor.withValues(alpha: 0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.disabledColor),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.disabledColor),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.whiteColor),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(width: 1, color: AppColor.errorColor),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
          width: 1, color: AppColor.errorColor.withValues(alpha: 0.5)),
    ),
  );
}

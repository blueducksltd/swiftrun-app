// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:swiftrun/common/styles/style.dart';

class AppChipTheme {
  AppChipTheme._();
  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: AppColor.disabledColor.withValues(alpha: 0.4),
    labelStyle: TextStyle(color: AppColor.blackColor),
    selectedColor: AppColor.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: AppColor.whiteColor,
  );
  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: AppColor.disabledColor.withValues(alpha: 0.4),
    labelStyle: TextStyle(color: AppColor.blackColor),
    selectedColor: AppColor.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: AppColor.whiteColor,
  );
}

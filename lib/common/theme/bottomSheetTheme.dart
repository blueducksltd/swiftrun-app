// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:swiftrun/common/styles/style.dart';

class AppBottomSheetTheme {
  AppBottomSheetTheme._();
  static BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: AppColor.whiteColor,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: AppColor.blackColor,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}

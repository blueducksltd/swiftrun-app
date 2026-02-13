// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:swiftrun/common/styles/style.dart';

class AppRadioTheme {
  AppRadioTheme._();

  static RadioThemeData radioThemeLight = RadioThemeData(
    fillColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColor.primaryColor
          : AppColor.primaryColor,
    ),
  );
}

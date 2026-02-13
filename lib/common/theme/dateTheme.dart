// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AppDateTheme {
  AppDateTheme._();
  static DatePickerThemeData datePickerTheme = DatePickerThemeData(
    elevation: 0,
    headerHeadlineStyle: const TextStyle().copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headerHelpStyle: const TextStyle().copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
  );
}

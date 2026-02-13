import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';

extension ListGutter on List<Widget> {
  List<Widget> separate(double space) => length <= 1
      ? this
      : sublist(1).fold(
          [first],
          (r, element) => [...r, Gap(space), element],
        );
}

// String? _validatePhoneNumber(String? value) {
//   final phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
//   if (!phoneExp.hasMatch(value!)) {
//     return phoneExp.toString();
//   }
//   return null;
// }

extension CurrencySymbolExtension on String {
  String getCurrencySymbol() {
    var format =
        NumberFormat.simpleCurrency(locale: Platform.localeName, name: this);
    return format.currencySymbol;
  }
}

extension EmailValidation on String {
  bool get emailValidation {
    final emailIsValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailIsValid.hasMatch(this);
  }
}

extension ValidatePhoneNumber on String? {
  String? validatePhoneNumber() {
    if (this == null || this!.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters for validation
    final digits = this!.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid length for any supported country
    // Accept 8 digits (Malta) or 10 digits (Nigeria, US, Canada)
    if (digits.length == 8 || digits.length == 10) {
      return null;
    } else {
      return 'Invalid phone number format';
    }
  }
}

errorMethod(String erorrMsg) {
  return Get.snackbar(
    icon: Icon(Icons.info, color: AppColor.whiteColor),
    backgroundColor: Colors.red,
    colorText: Colors.white,
    "Error Occured",
    erorrMsg,
  );
}

successMethod(String successmsg) {
  return Get.snackbar(
    icon: Icon(Icons.info, color: AppColor.whiteColor),
    backgroundColor: AppColor.primaryColor,
    colorText: Colors.white,
    "Success",
    successmsg,
  );
}

infoMethod(String msg) {
  return Get.snackbar(
    icon: Icon(Icons.info_outline, color: AppColor.whiteColor),
    backgroundColor: AppColor.primaryColor,
    colorText: Colors.white,
    "Update",
    msg,
  );
}

String formatDuration(int totalSeconds) {
  final int minutes = totalSeconds ~/ 60;
  final int seconds = totalSeconds % 60;

  return '$minutes mins $seconds secs';
}

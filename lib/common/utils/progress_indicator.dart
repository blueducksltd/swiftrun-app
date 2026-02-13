import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:swiftrun/common/styles/colors.dart';

class ProgressDialogUtils {
  static bool isProgressVisible = false;

  ///common method for showing progress dialog
  static void showProgressDialog({isCancellable = false}) async {
    if (!isProgressVisible) {
      Get.dialog(
        Center(
          child: Container(
            height: 80.w,
            width: 80.w,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColor.blackColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColor.whiteColor,
              ),
            ),
          ),
        ),
        barrierDismissible: isCancellable,
      );
      isProgressVisible = true;
    }
  }

  ///common method for hiding progress dialog
  static void hideProgressDialog() {
    if (isProgressVisible) Get.back();
    isProgressVisible = false;
  }
}

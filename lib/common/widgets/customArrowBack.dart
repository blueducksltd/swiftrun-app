// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';

class CustomArrowBack extends StatelessWidget {
  const CustomArrowBack({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: screenWidth(context, percent: 0.08),
        height: screenWidth(context, percent: 0.08),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.primaryColor,
        ),
        child: Icon(
          Icons.arrow_back,
          color: AppColor.whiteColor,
          size: 20,
        ),
      ),
    );
  }
}

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/size.dart';

class AddWithdrawButton extends StatelessWidget {
  final double? width;
  final Widget child;
  final VoidCallback onTap;
  const AddWithdrawButton({
    super.key,
    this.width,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: screenHeight(context, percent: 0.04),
        width: width,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: AppColor.whiteColor),
        child: child,
      ),
    );
  }
}

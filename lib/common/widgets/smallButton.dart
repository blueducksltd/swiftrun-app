// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class SmallButton extends StatelessWidget {
  final double width;
  final Widget child;
  final bool isColor;
  final VoidCallback onTap;
  const SmallButton({
    super.key,
    required this.width,
    required this.child,
    this.isColor = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isColor
              ? AppColor.primaryColor
              : AppColor.disabledColor.withValues(alpha: 0.5),
        ),
        child: child,
      ),
    );
  }
}

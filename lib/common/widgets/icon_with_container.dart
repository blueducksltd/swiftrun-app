import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiftrun/common/styles/style.dart';

class IconWihContainer extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  const IconWihContainer({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColor.primaryColor.withValues(alpha: 0.1),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: AppColor.primaryColor,
        ),
      ),
    );
  }
}

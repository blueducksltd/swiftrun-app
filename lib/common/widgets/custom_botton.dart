// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:swiftrun/common/utils/utils.dart';

class ButtonWidget extends StatelessWidget {
  final Function() onTap;

  final Color color;
  final bool isEnable, isHeight;
  final Widget widget;
  final double? height;

  const ButtonWidget({
    super.key,
    required this.onTap,
    required this.color,
    required this.widget,
    this.isEnable = true,
    this.height,
    this.isHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          alignment: Alignment.center,
          width: double.maxFinite,
          height: isHeight ? height : screenHeight(context, percent: 0.055),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isEnable ? color : color.withValues(alpha: 0.5),
          ),
          child: widget),
    );
  }
}

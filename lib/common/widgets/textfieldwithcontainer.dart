import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/widgets/customTextfield.dart';

class TextFieldWIthContainer extends StatelessWidget {
  final String title, hint;
  final Widget? icon;
  final bool isEnable;
  final Widget? rightIcon;
  final Function(String)? onChange;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWIthContainer({
    super.key,
    required this.title,
    required this.hint,
    this.icon,
    this.onChange,
    this.rightIcon,
    this.controller,
    this.isEnable = true,
    this.keyboardType,
    this.helperText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: AppColor.disabledColor),
          ),
          6.verticalSpace,
          RoundTextField(
            isEnable: isEnable,
            controller: controller,
            onChange: onChange,
            rigtIcon: rightIcon,
            hitText: hint,
            icon: icon,
            keyboardType: keyboardType,
            inputFormater: inputFormatters,
          ),
          if (helperText != null) ...[
            6.verticalSpace,
            Text(
              helperText!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColor.disabledColor),
            )
          ],
        ],
      ),
    );
  }
}

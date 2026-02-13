// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swiftrun/common/styles/colors.dart';

class RoundTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String hitText;
  final int? maxText;
  final int? maxLine;
  final Widget? icon;
  final Widget? rigtIcon;
  final String? prefixText;
  final bool obscureText;
  final bool isError;
  final bool? isEnable;
  final EdgeInsets? margin;
  final String? errorText;
  final String? labelText;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormater;
  final Function(String)? onChange;
  // final TextStyle style;

  final String? Function(String?)? validator;
  const RoundTextField({
    super.key,
    required this.hitText,
    this.icon,
    this.controller,
    this.margin,
    this.keyboardType,
    this.obscureText = false,
    this.rigtIcon,
    this.isError = false,
    this.isEnable = true,
    this.errorText,
    this.validator,
    this.labelText,
    this.onChange,
    this.inputFormater,
    this.prefixText,
    this.maxText,
    this.focusNode,
    this.maxLine,
    // required this.style,
  });

  @override
  State<RoundTextField> createState() => _RoundTextFieldState();
}

class _RoundTextFieldState extends State<RoundTextField> {
  final focusNode = FocusNode();
  bool stateIsError = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // height: Platform.isIOS ? 40.h : 0,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: AppColor.disabledColor.withOpacity(0.1),
            // border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enabled: widget.isEnable,
            focusNode: focusNode,
            onChanged: widget.onChange,
            inputFormatters: widget.inputFormater,
            maxLength: widget.maxText,
            maxLines: widget.maxLine ?? 1,
            style: Theme.of(context).textTheme.bodyMedium,
            validator: widget.validator,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                // vertical: 18,
                horizontal: 20,
              ),
              errorText: _errorText,
              labelText: widget.labelText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: widget.icon,
              hintText: widget.hitText,
              suffixIcon: widget.rigtIcon,
              filled: true,
              fillColor: AppColor.textFieldFill,
              hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColor.disabledColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomMaterialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final TextStyle style;
  final String name;
  const CustomMaterialButton({
    super.key,
    required this.onPressed,
    required this.style,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(
        name,
        style: style,
      ),
    );
  }
}

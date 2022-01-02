import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double fontSize;
  final bool isMultiline;

  const MyTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    this.fontSize = 24,
    this.isMultiline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Palette.text1, fontSize: 12),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize),
          maxLines: isMultiline ? 4 : 1,
        ),
      ],
    );
  }
}

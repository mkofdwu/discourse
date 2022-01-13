import 'dart:async';

import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final bool fillWidth;
  final bool isLoading;
  final IconData? suffixIcon;
  final FutureOr<dynamic> Function() onPressed;

  const MyButton({
    Key? key,
    required this.text,
    this.isPrimary = true,
    this.fillWidth = false,
    this.isLoading = false,
    this.suffixIcon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpacityFeedback(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // 12
        decoration: BoxDecoration(
          color: isPrimary
              ? Get.theme.colorScheme.primary
              : Palette.black3, // Get.theme.primaryColorLight,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: fillWidth ? Alignment.center : null,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: isPrimary ? Colors.black : Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isPrimary ? Colors.black : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (suffixIcon != null) SizedBox(width: 8),
                  if (suffixIcon != null)
                    Icon(
                      suffixIcon!,
                      color: isPrimary ? Colors.black : Colors.white,
                      size: 16,
                    ),
                ],
              ),
      ),
    );
  }
}

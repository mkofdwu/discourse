import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData iconData;
  final Color? color;
  final double? size;
  final Function() onPressed;

  const MyIconButton(
    this.iconData, {
    Key? key,
    this.color,
    this.size,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpacityFeedback(
      onPressed: onPressed,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Icon(iconData, size: size, color: color),
        ),
      ),
    );
  }
}

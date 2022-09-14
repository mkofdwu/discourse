import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData iconData;
  final Color? color;
  final double? size;
  final double? boxSize;
  final Function() onPressed;

  const MyIconButton(
    this.iconData, {
    Key? key,
    this.color,
    this.size,
    this.boxSize,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpacityFeedback(
      onPressed: onPressed,
      child: Container(
        width: boxSize ?? 48,
        height: boxSize ?? 48,
        color: Colors.transparent, // make entire area clickable
        child: Center(
          child: Icon(iconData, size: size, color: color),
        ),
      ),
    );
  }
}

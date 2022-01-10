import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  final IconData iconData;
  final Function() onPressed;

  const MyFloatingActionButton({
    Key? key,
    required this.iconData,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpacityFeedback(
      onPressed: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Palette.orange,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Icon(iconData, size: 20),
        ),
      ),
    );
  }
}

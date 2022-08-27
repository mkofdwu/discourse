import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  final IconData iconData;
  final bool isPrimary;
  final Function() onPressed;

  const MyFloatingActionButton({
    Key? key,
    required this.iconData,
    this.isPrimary = true,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpacityFeedback(
      onPressed: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? Palette.orange : Palette.black3,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            iconData,
            color: isPrimary ? Colors.black : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

import 'package:discourse/widgets/pressed_builder.dart';
import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData iconData;
  final Widget? child;
  final Function() onPressed;

  const MyIconButton(
    this.iconData, {
    Key? key,
    this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PressedBuilder(
      onPressed: onPressed,
      builder: (pressed) => AnimatedContainer(
        width: 36,
        height: 36,
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(pressed ? 0.1 : 0),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: child ?? Icon(iconData, size: 24),
        ),
      ),
    );
  }
}

import 'package:discourse/widgets/pressed_builder.dart';
import 'package:flutter/material.dart';

class OpacityFeedback extends StatelessWidget {
  final double pressedOpacity;
  final Function() onPressed;
  final Widget child;

  const OpacityFeedback({
    Key? key,
    this.pressedOpacity = 0.4,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PressedBuilder(
      onPressed: onPressed,
      animationDuration: 100,
      builder: (pressed) => AnimatedOpacity(
        opacity: pressed ? pressedOpacity : 1,
        duration: const Duration(milliseconds: 100),
        child: child,
      ),
    );
  }
}

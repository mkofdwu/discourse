import 'package:discourse/widgets/pressed_builder.dart';
import 'package:flutter/material.dart';

class OpacityFeedback extends StatelessWidget {
  final Widget child;
  final double pressedOpacity;
  final Function() onPressed;

  const OpacityFeedback({
    Key? key,
    required this.child,
    this.pressedOpacity = 0.4,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PressedBuilder(
      onPressed: onPressed,
      builder: (pressed) => AnimatedOpacity(
        opacity: pressed ? pressedOpacity : 1,
        duration: const Duration(milliseconds: 100),
        child: child,
      ),
    );
  }
}

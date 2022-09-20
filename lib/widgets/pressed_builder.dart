import 'dart:async';

import 'package:flutter/material.dart';

class PressedBuilder extends StatefulWidget {
  final Function() onPressed;
  final Function()? onLongPress;
  final int animationDuration;
  final Widget Function(bool) builder;

  const PressedBuilder({
    Key? key,
    required this.onPressed,
    this.onLongPress,
    this.animationDuration = 200,
    required this.builder,
  }) : super(key: key);

  @override
  PressedBuilderState createState() => PressedBuilderState();
}

class PressedBuilderState extends State<PressedBuilder> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        Future.delayed(Duration(milliseconds: widget.animationDuration), () {
          widget.onPressed();
          setState(() => _pressed = false);
        });
      },
      onTapCancel: () => setState(() => _pressed = false),
      onLongPress: widget.onLongPress,
      child: widget.builder(_pressed),
    );
  }
}

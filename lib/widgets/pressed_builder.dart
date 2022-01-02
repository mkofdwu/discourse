import 'package:flutter/material.dart';

class PressedBuilder extends StatefulWidget {
  final Function onPressed;
  final Widget Function(bool) builder;

  const PressedBuilder(
      {Key? key, required this.onPressed, required this.builder})
      : super(key: key);

  @override
  _PressedNotifierState createState() => _PressedNotifierState();
}

class _PressedNotifierState extends State<PressedBuilder> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: widget.builder(_pressed),
    );
  }
}

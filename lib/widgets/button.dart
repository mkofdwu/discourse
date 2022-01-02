import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/pressed_builder.dart';

class MyButton extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool fillWidth;
  final Function onPressed;

  const MyButton({
    Key? key,
    required this.text,
    this.isDark = true,
    this.fillWidth = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PressedBuilder(
      onPressed: onPressed,
      builder: (pressed) => Transform.scale(
        scale: pressed ? 0.96 : 1,
        child: fillWidth
            ? _buildDisplay(context)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [_buildDisplay(context)],
              ),
      ),
    );
  }

  Widget _buildDisplay(BuildContext context) => Container(
        height: 40,
        decoration: BoxDecoration(
          color:
              isDark ? Theme.of(context).colorScheme.secondary : Palette.light0,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 26),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

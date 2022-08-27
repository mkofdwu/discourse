import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final String text;

  const TypingIndicator({Key? key, required this.text}) : super(key: key);

  @override
  TypingIndicatorState createState() => TypingIndicatorState();
}

class TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(_waveController);
    _waveController.addListener(() => setState(() {}));
    _waveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _waveController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _waveController.forward();
      }
    });
    _waveController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDots(),
        SizedBox(width: 8), // spacing is actually 12 because of dot
        Text(
          widget.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDots() => Row(
        children: List.generate(3, (i) {
          var val = _waveAnimation.value + i * .3;
          if (val > 1) {
            val = 2 - val;
          }
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(val),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
}

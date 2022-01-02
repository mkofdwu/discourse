import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';

class TypingIndicator extends StatefulWidget {
  final String text;

  const TypingIndicator({Key? key, required this.text}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
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
    return Container(
      decoration: BoxDecoration(
        color: Palette.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDots(),
          SizedBox(height: 10),
          Text(widget.text, style: TextStyle(color: Colors.white)),
        ],
      ),
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
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(val),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
}

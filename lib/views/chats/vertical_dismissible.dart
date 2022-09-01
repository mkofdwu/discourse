import 'package:flutter/material.dart';

class VerticalDismissible extends StatefulWidget {
  final int threshold;
  final Widget child;
  final Function() onDismiss;

  const VerticalDismissible({
    Key? key,
    required this.threshold,
    required this.child,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<VerticalDismissible> createState() => _VerticalDismissibleState();
}

class _VerticalDismissibleState extends State<VerticalDismissible>
    with TickerProviderStateMixin {
  late double _startY;
  double _dy = 0; // distance moved

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        _startY = details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        double dist = details.globalPosition.dy - _startY;
        // for now can only move in the negative direction
        if (dist > 0) return;
        setState(() => _dy = dist);
      },
      onVerticalDragEnd: (details) {
        if (_dy < widget.threshold) {
          widget.onDismiss();
          // very hacky
          // reset dy for the next time it goes down
          Future.delayed(Duration(milliseconds: 300), () => _dy = 0);
        } else {
          // animate back to original position
          final controller = AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 200),
          );
          final animation = Tween(begin: _dy, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut))
              .animate(controller);
          animation.addListener(() {
            setState(() {
              _dy = animation.value;
            });
          });
          controller.forward();
        }
      },
      child: Transform.translate(offset: Offset(0, _dy), child: widget.child),
    );
  }
}

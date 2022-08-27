import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class ReplyGesture extends StatefulWidget {
  final Widget child;
  final Function onReply;
  final bool accountForWidth;

  const ReplyGesture({
    Key? key,
    required this.child,
    required this.onReply,
    required this.accountForWidth, // equal to !message.fromMe
  }) : super(key: key);

  @override
  ReplyGestureState createState() => ReplyGestureState();
}

class ReplyGestureState extends State<ReplyGesture>
    with TickerProviderStateMixin {
  static const double _climax = 60;
  late double _horizontalDragStart;
  double _horizontalDragDist = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _horizontalDragStart = details.globalPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        double dist = details.globalPosition.dx - _horizontalDragStart;
        if (dist <= 0) return;
        if (dist > _climax) {
          dist = _climax + pow(dist - _climax, 0.7);
        }
        setState(() => _horizontalDragDist = dist);
      },
      onHorizontalDragEnd: (details) {
        if (_horizontalDragDist > _climax) widget.onReply();
        // animate back to original position
        final controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
        );
        final animation = Tween(begin: _horizontalDragDist, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut))
            .animate(controller);
        animation.addListener(() {
          setState(() {
            _horizontalDragDist = animation.value;
          });
        });
        controller.forward();
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedScale(
              duration: Duration(milliseconds: 200),
              scale: _horizontalDragDist > _climax ? 1 : 0,
              alignment: Alignment.center,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: _horizontalDragDist > _climax ? 1 : 0,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(left: 30, top: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF484848),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    FluentIcons.arrow_reply_16_regular,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: Offset(
                  widget.accountForWidth
                      ? _horizontalDragDist - 54
                      : _horizontalDragDist,
                  0,
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

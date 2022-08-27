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

class ReplyGestureState extends State<ReplyGesture> {
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
        setState(() {
          _horizontalDragDist =
              details.globalPosition.dx - _horizontalDragStart;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_horizontalDragDist > _climax) widget.onReply();
        setState(() {
          _horizontalDragDist = 0;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_horizontalDragDist > _climax)
              Container(
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
            Expanded(
              child: Transform.translate(
                offset: Offset(
                  _horizontalDragDist > _climax && widget.accountForWidth
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

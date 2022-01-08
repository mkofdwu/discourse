import 'dart:math';

import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryBorderPainter extends CustomPainter {
  int seenNum;
  int storyNum;

  StoryBorderPainter({
    required this.seenNum,
    required this.storyNum,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2
      ..color = Palette.orange
      ..style = PaintingStyle.stroke;
    if (storyNum == 1) {
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        0,
        2 * pi,
        false,
        paint,
      );
    } else {
      double sweepAngle = 360 / storyNum - 6;
      for (int i = 0; i < storyNum; i++) {
        if (i == seenNum) {
          paint.color = Get.theme.primaryColor.withOpacity(0.2);
        }
        canvas.drawArc(
          Rect.fromLTWH(0, 0, size.width, size.height),
          _degToRad(i * 360 / storyNum - 90),
          _degToRad(sweepAngle),
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

_degToRad(double deg) {
  return deg * pi / 180;
}

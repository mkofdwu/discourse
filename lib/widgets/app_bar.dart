import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

PreferredSize myAppBar({
  required String title,
  Map<IconData, Function()>? actions,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(76),
    child: SafeArea(
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        color: Get.theme.primaryColorLight,
        child: Row(
          children: [
            OpacityFeedback(
              child: Icon(FluentIcons.chevron_left_20_regular),
              onPressed: () => Get.back(),
            ),
            SizedBox(width: 24),
            Text(
              title,
              style: TextStyle(
                height: 1.4, // center it properly
                fontFamily: 'Avenir',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            ...(actions ?? {})
                .map(
                  (iconData, onPressed) => MapEntry(iconData,
                      GestureDetector(child: Icon(iconData), onTap: onPressed)),
                )
                .values
                .toList(),
          ],
        ),
      ),
    ),
  );
}
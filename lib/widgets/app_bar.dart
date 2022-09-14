import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

PreferredSize myAppBar({
  required String title,
  Map<IconData, Function()>? actions,
  Function()? onBack,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(76),
    child: SafeArea(
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Palette.black3,
        child: Row(
          children: [
            MyIconButton(
              FluentIcons.chevron_left_24_filled,
              onPressed: onBack ?? () => Get.back(),
            ),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                height: 1.8, // center it properly
                fontFamily: 'Avenir',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            ...(actions ?? {})
                .map(
                  (iconData, onPressed) => MapEntry(
                    iconData,
                    MyIconButton(iconData, onPressed: onPressed),
                  ),
                )
                .values
                .toList(),
          ],
        ),
      ),
    ),
  );
}

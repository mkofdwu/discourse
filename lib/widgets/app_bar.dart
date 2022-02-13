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
        padding: const EdgeInsets.symmetric(horizontal: 28),
        color: Get.theme.primaryColorLight,
        child: Row(
          children: [
            MyIconButton(
              FluentIcons.chevron_left_20_regular,
              onPressed: onBack ?? () => Get.back(),
            ),
            SizedBox(width: 12),
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
                  (iconData, onPressed) => MapEntry(
                      iconData,
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: MyIconButton(iconData, onPressed: onPressed),
                      )),
                )
                .values
                .toList(),
          ],
        ),
      ),
    ),
  );
}

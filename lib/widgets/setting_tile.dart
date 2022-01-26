import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingTile extends StatelessWidget {
  final String name;
  final String? description;
  final Widget? trailing;
  final Widget? bottom;
  final bool isDangerous;
  final Function()? onPressed;

  const SettingTile({
    Key? key,
    required this.name,
    this.description,
    this.trailing,
    this.bottom,
    this.isDangerous = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return onPressed == null
        ? _mainUi(false)
        : PressedBuilder(
            onPressed: onPressed!,
            builder: _mainUi,
          );
  }

  Widget _mainUi(bool pressed) => Container(
        decoration: BoxDecoration(
          color: (pressed || onPressed == null)
              ? Palette.black2
              : Color(0xFF262626),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isDangerous
                              ? Palette.red
                              : Get.theme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description != null) SizedBox(height: 14),
                      if (description != null)
                        Text(description!, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                trailing ??
                    Icon(
                      FluentIcons.chevron_right_20_filled,
                      color: isDangerous ? Palette.red : Get.theme.primaryColor,
                      size: 20,
                    ),
              ],
            ),
            if (bottom != null)
              Container(
                width: double.infinity,
                height: 1,
                margin: const EdgeInsets.only(top: 14, bottom: 20),
                color: Get.theme.primaryColor.withOpacity(0.1),
              ),
            if (bottom != null) bottom!,
          ],
        ),
      );
}

import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? tag;
  final String? photoUrl;
  final IconData iconData; // icon displayed if photoUrl is null
  final List<Widget> extraWidgets;
  final bool isSelected;
  final Function()? onPressed;

  const MyListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.photoUrl,
    required this.iconData,
    this.extraWidgets = const [],
    this.isSelected = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return onPressed == null
        ? _buildPressed(false)
        : PressedBuilder(
            onPressed: onPressed!,
            builder: _buildPressed,
          );
  }

  Widget _buildPressed(bool pressed) => FractionallySizedBox(
        widthFactor: 1.16,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(pressed ? 0.08 : 0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: <Widget>[
              Stack(
                children: [
                  PhotoOrIcon(
                    size: 50,
                    iconSize: 20,
                    photoUrl: photoUrl,
                    placeholderIcon: isSelected ? null : iconData,
                  ),
                  if (isSelected)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        border: Border.all(color: Palette.orange, width: 2),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Center(
                        child: Icon(
                          FluentIcons.checkmark_16_filled,
                          color: Palette.orange,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: subtitle == null ? 18 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        if (tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Palette.orange.withOpacity(0.6),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tag!,
                              style: TextStyle(
                                color: Palette.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (subtitle != null) SizedBox(height: 8),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Get.theme.primaryColor.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              ...extraWidgets,
            ],
          ),
        ),
      );
}

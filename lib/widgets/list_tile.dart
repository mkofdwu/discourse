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
  final Function()? onLongPress;
  final bool increaseWidthFactor;
  final bool compact;
  final bool isActionTile;

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
    this.onLongPress,
    this.increaseWidthFactor = true,
    this.compact = false,
    this.isActionTile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return onPressed == null
        ? _buildPressed(false)
        : PressedBuilder(
            onPressed: onPressed!,
            onLongPress: onLongPress,
            builder: _buildPressed,
          );
  }

  Widget _buildPressed(bool pressed) => FractionallySizedBox(
        widthFactor: increaseWidthFactor ? 1.16 : 1,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: compact ? 8 : 10,
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(pressed ? 0.08 : 0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: <Widget>[
              Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        width: 2,
                        color: isSelected ? Palette.orange : Colors.transparent,
                      ),
                    ),
                    child: PhotoOrIcon(
                      size: compact ? 46 : 50,
                      iconSize: 20,
                      photoUrl: photoUrl,
                      placeholderIcon: iconData,
                      backgroundColor:
                          isActionTile ? Palette.black3 : Color(0xFF606060),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: AnimatedScale(
                      duration: Duration(milliseconds: 200),
                      scale: isSelected ? 1 : 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Palette.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            FluentIcons.checkmark_12_filled,
                            color: Colors.black,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: compact ? 14 : 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: subtitle == null ? 18 : 16,
                              fontWeight: isActionTile
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
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
                    if (subtitle != null) SizedBox(height: compact ? 4 : 8),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          color: Get.theme.primaryColor.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (extraWidgets.isNotEmpty) SizedBox(width: 12),
              ...extraWidgets,
            ],
          ),
        ),
      );
}

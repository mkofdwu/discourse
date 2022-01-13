import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? photoUrl;
  final IconData iconData; // icon displayed if photoUrl is null
  final Map<IconData, Function()> suffixIcons;
  final bool isSelected;
  final Function() onPressed;

  const MyListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.photoUrl,
    required this.iconData,
    this.suffixIcons = const {},
    this.isSelected = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Material(
        // makes entire tile clickable
        color: Colors.transparent,
        child: Row(
          children: <Widget>[
                Stack(
                  children: [
                    PhotoView(
                      photoUrl: photoUrl,
                      placeholderIcon: isSelected ? null : iconData,
                    ),
                    if (isSelected)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          border: Border.all(color: Palette.orange, width: 2),
                          borderRadius: BorderRadius.circular(20),
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
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Get.theme.primaryColor.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ] +
              suffixIcons
                  .map((iconData, onTapIcon) => MapEntry(
                        iconData,
                        OpacityFeedback(
                          onPressed: onTapIcon,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(iconData, size: 20),
                          ),
                        ),
                      ))
                  .values
                  .toList(),
        ),
      ),
    );
  }
}

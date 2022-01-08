import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? photoUrl;
  final IconData iconData; // icon displayed if photoUrl is null
  final Map<IconData, Function()> suffixIcons;
  final Function() onPressed;

  const MyListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.photoUrl,
    required this.iconData,
    required this.suffixIcons,
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
                photoUrl == null
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: photoUrl == null ? Palette.black3 : null,
                        ),
                        child: Center(child: Icon(iconData, size: 16)),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(photoUrl!),
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
                        GestureDetector(
                          onTap: onTapIcon,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
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

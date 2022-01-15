import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';

class PhotoOrIcon extends StatelessWidget {
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final String? photoUrl;
  final IconData? placeholderIcon;

  const PhotoOrIcon({
    Key? key,
    this.size = 40,
    this.iconSize = 16,
    this.backgroundColor = Palette.black3,
    required this.photoUrl,
    required this.placeholderIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return photoUrl == null
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
              color: backgroundColor,
            ),
            child: Center(
              child: Icon(placeholderIcon, size: iconSize),
            ),
          )
        : CircleAvatar(
            radius: size / 2,
            backgroundImage: CachedNetworkImageProvider(photoUrl!),
          );
  }
}

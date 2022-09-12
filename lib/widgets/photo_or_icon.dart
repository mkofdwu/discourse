import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';

class PhotoOrIcon extends StatelessWidget {
  final double size;
  final double iconSize;
  final double iconOpacity;
  final double? radius; // if is not a circle
  final Color backgroundColor;
  final String? photoUrl;
  final File? photoFile;
  final IconData? placeholderIcon;
  final bool hero;

  const PhotoOrIcon({
    Key? key,
    this.size = 40,
    this.iconSize = 16,
    this.iconOpacity = 1,
    this.radius,
    this.backgroundColor = Palette.black3,
    required this.photoUrl,
    this.photoFile,
    required this.placeholderIcon,
    this.hero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null && photoFile == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? size / 2),
          color: backgroundColor,
        ),
        child: Center(
          child: Icon(
            placeholderIcon,
            size: iconSize,
            color: Colors.white.withOpacity(iconOpacity),
          ),
        ),
      );
    }

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size / 2),
      child: photoFile != null
          ? Image.file(photoFile!, fit: BoxFit.cover)
          : CachedNetworkImage(imageUrl: photoUrl!, fit: BoxFit.cover),
    );
    return SizedBox(
      width: size,
      height: size,
      child: hero
          ? Hero(
              tag: photoFile != null ? photoFile!.path : photoUrl!,
              child: imageWidget,
            )
          : imageWidget,
    );
  }
}

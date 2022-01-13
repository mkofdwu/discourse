import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';

class PhotoView extends StatelessWidget {
  final String? photoUrl;
  final IconData? placeholderIcon;

  const PhotoView({
    Key? key,
    required this.photoUrl,
    required this.placeholderIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return photoUrl == null
        ? Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Palette.black3,
            ),
            child: Center(
              child: Icon(placeholderIcon, size: 16),
            ),
          )
        : CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(photoUrl!),
          );
  }
}

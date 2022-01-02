import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  final double size;
  final String? url;
  final IconData placeholderIcon;

  const ProfilePhoto({
    Key? key,
    required this.size,
    this.url,
    this.placeholderIcon = FluentIcons.person_20_regular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        color: Colors.black.withOpacity(0.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? Center(child: Icon(placeholderIcon))
          : CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover),
    );
  }
}

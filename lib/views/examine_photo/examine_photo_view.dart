import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:discourse/models/photo.dart';

class ExaminePhotoView extends StatefulWidget {
  final String title;
  final Photo photo;
  final String? caption;
  final Map<IconData, Function()> suffixIcons;

  const ExaminePhotoView({
    Key? key,
    this.title = 'View photo',
    required this.photo,
    this.caption,
    this.suffixIcons = const {},
  }) : super(key: key);

  @override
  State<ExaminePhotoView> createState() => _ExaminePhotoViewState();
}

class _ExaminePhotoViewState extends State<ExaminePhotoView> {
  bool _zoomedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            backgroundDecoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            minScale: PhotoViewComputedScale.contained,
            scaleStateChangedCallback: (scaleState) {
              if (scaleState.name == 'zoomedIn') {
                setState(() => _zoomedIn = true);
              } else {
                setState(() => _zoomedIn = false);
              }
            },
            heroAttributes: PhotoViewHeroAttributes(tag: widget.photo.heroTag),
            imageProvider: widget.photo.isLocal
                ? FileImage(widget.photo.file!) as ImageProvider
                : CachedNetworkImageProvider(widget.photo.url!),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              30,
              28 + Get.mediaQuery.padding.top,
              30,
              28,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0),
                ],
              ),
            ),
            child: Row(
              children: [
                MyIconButton(
                  FluentIcons.chevron_left_24_regular,
                  onPressed: Get.back,
                ),
                SizedBox(width: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.8,
                  ),
                ),
                Spacer(),
                ...widget.suffixIcons
                    .map((iconData, onPressed) => MapEntry(
                          iconData,
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: MyIconButton(iconData, onPressed: onPressed),
                          ),
                        ))
                    .values,
              ],
            ),
          ),
          if (widget.caption != null && !_zoomedIn)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(50, 80, 50, 42),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0),
                    ],
                  ),
                ),
                child: Text(
                  widget.caption!,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

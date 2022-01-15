import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:discourse/models/photo.dart';

class ExaminePhotoView extends StatelessWidget {
  final Photo photo;

  const ExaminePhotoView({Key? key, required this.photo}) : super(key: key);

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
            imageProvider: photo.isLocal
                ? FileImage(photo.file!) as ImageProvider
                : CachedNetworkImageProvider(photo.url!),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 40),
              child: OpacityFeedback(
                onPressed: Get.back,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Icon(FluentIcons.chevron_left_20_regular, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'BACK',
                      style: TextStyle(
                          fontWeight: FontWeight.w500, letterSpacing: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

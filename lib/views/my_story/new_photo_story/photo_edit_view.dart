import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import 'photo_edit_controller.dart';

class PhotoEditView extends StatelessWidget {
  final Photo photo;

  const PhotoEditView({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhotoEditController>(
      init: PhotoEditController(photo),
      builder: (controller) => Scaffold(
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyIconButton(
                    FluentIcons.chevron_left_24_regular,
                    onPressed: Get.back,
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Edit photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                  MyIconButton(
                    FluentIcons.checkmark_24_regular,
                    onPressed: controller.submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

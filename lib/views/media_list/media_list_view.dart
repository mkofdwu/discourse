import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/models/db_objects/message_media_url.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/choice_chip.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'media_list_controller.dart';

class MediaListView extends StatelessWidget {
  final List<MessageMedia> media;

  const MediaListView({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MediaListController>(
      init: MediaListController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Photos and videos'),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(44, 30, 44, 0),
          child: Column(
            children: [
              Row(
                children: [
                  MyChoiceChip(
                    text: 'Photos',
                    onChanged: (selected) {},
                  ),
                  SizedBox(width: 16),
                  MyChoiceChip(
                    text: 'Videos',
                    onChanged: (selected) {},
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  padding: const EdgeInsets.only(bottom: 60),
                  children: media
                      .map((media) => OpacityFeedback(
                            onPressed: () => controller.toExaminePhoto(media),
                            child: Hero(
                              tag: media.photoUrl,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: media.photoUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

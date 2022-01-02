import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:discourse/models/photo.dart';

class ExaminePhotoView extends StatelessWidget {
  final Photo photo;

  const ExaminePhotoView({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        minScale: PhotoViewComputedScale.contained,
        imageProvider: photo.isLocal
            ? FileImage(photo.file!) as ImageProvider
            : CachedNetworkImageProvider(photo.url!),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:discourse/models/message.dart';
import 'package:discourse/utils/format_date_time.dart';

class PhotoMessageView extends StatelessWidget {
  final Message message;
  final bool isSelected;
  final bool isSent;

  const PhotoMessageView({
    Key? key,
    required this.message,
    required this.isSelected,
    required this.isSent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.transparent,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: message.photo!.url!,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 24,
                left: 14,
                right: 14,
                bottom: 14,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(1),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text!,
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(message.sentTimestamp),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(width: 4),
                      if (!isSent) CircularProgressIndicator(strokeWidth: 1),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

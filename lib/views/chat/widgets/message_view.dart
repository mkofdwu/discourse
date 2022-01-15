import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/utils/format_date_time.dart';
import 'package:discourse/views/chat/widgets/reply_gesture.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'message_controller.dart';

class MessageView extends StatelessWidget {
  final Message message;

  const MessageView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      global: false,
      init: MessageController(message),
      builder: (controller) => ReplyGesture(
        onReply: controller.replyToThis,
        accountForWidth: !message.fromMe,
        child: Container(
          // selection indicator
          color:
              controller.isSelected() ? Palette.orange.withOpacity(0.1) : null,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
          child: GestureDetector(
            onTap: controller.onTap,
            onLongPress: controller.toggleSelectMessage,
            child: Row(
              mainAxisAlignment: message.fromMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  decoration: BoxDecoration(
                    color: message.fromMe
                        ? Palette.orange
                        : Get.theme.primaryColorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias, // image circular borders
                  child: Column(
                    children: [
                      if (message.photo != null)
                        _buildPhotoView(message.photo!),
                      Container(
                        width: message.photo != null ? 200 : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: IntrinsicWidth(
                          child: Column(
                            // crossAxisAlignment: message.fromMe
                            //     ? CrossAxisAlignment.end
                            //     : CrossAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (message.repliedMessage != null)
                                _buildRepliedMessageView(
                                  message.repliedMessage!,
                                  controller.getRepliedMessageColor(),
                                ),
                              _buildFancyTextAndTimestampWrap(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoView(Photo photo) =>
      CachedNetworkImage(imageUrl: photo.url!, width: 200);

  Widget _buildRepliedMessageView(RepliedMessage repliedMessage, Color color) =>
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Get.theme.primaryColor.withOpacity(0.1),
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 12),
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.rotate(
              angle: pi,
              child: Icon(FluentIcons.text_quote_20_filled, size: 20),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Opacity(
                opacity: 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repliedMessage.sender.username,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      repliedMessage.text!,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFancyTextAndTimestampWrap() => Stack(
        children: [
          RichText(
            text: TextSpan(
              text: message.text! + '  ',
              style: TextStyle(
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: formatTime(message.sentTimestamp),
                  style: TextStyle(
                    color: Colors.transparent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              formatTime(message.sentTimestamp),
              style: TextStyle(
                color: Get.theme.primaryColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
}

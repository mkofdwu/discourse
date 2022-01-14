import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/format_date_time.dart';
import 'package:discourse/views/chat/widgets/reply_gesture.dart';
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
          color:
              controller.isSelected() ? Palette.orange.withOpacity(0.1) : null,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
          child: Row(
            mainAxisAlignment: message.fromMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: controller.onTap,
                onLongPress: controller.toggleSelectMessage,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: message.fromMe
                        ? Palette.orange
                        : Get.theme.primaryColorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: message.fromMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text!,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formatTime(message.sentTimestamp),
                        style: TextStyle(
                          color: Get.theme.primaryColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

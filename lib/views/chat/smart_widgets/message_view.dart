import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:discourse/models/message.dart';
import 'package:discourse/views/chat/dumb_widgets/photo_message_view.dart';
import 'package:discourse/views/chat/dumb_widgets/replied_message_view.dart';
import 'package:discourse/views/chat/dumb_widgets/text_message_view.dart';
import 'package:discourse/views/chat/dumb_widgets/reply_gesture.dart';
import 'package:get/get.dart';

import 'message_controller.dart';

class MessageView extends StatelessWidget {
  final Message message;
  final bool isSent;

  const MessageView({Key? key, required this.message, required this.isSent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: _builder);
  }

  Widget _builder(MessageController controller) => ReplyGesture(
        onReply: controller.replyToThis,
        accountForWidth: !message.fromMe,
        child: GestureDetector(
          onTap: controller.onTap,
          onLongPress: controller.toggleSelectMessage,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: message.fromMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.repliedMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RepliedMessageView(message: message.repliedMessage!),
                  ),
                _buildMessageSelectionIndicator(
                  controller.isSelected(),
                  message.photo == null
                      ? TextMessageView(
                          message: message,
                          isSelected: controller.isSelected(),
                          isSent: isSent,
                        )
                      : PhotoMessageView(
                          message: message,
                          isSelected: controller.isSelected(),
                          isSent: isSent,
                        ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildMessageSelectionIndicator(bool isSelected, Widget child) =>
      Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          if (isSelected)
            Positioned.fill(
              left: message.fromMe ? -10 : 0,
              right: !message.fromMe ? -10 : 0,
              child: Align(
                alignment: message.fromMe
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    FluentIcons.check_20_regular,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ),
        ],
      );
}

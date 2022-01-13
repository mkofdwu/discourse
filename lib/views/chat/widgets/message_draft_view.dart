import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'message_draft_controller.dart';

class MessageDraftView extends StatelessWidget {
  const MessageDraftView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageDraftController>(
      init: MessageDraftController(),
      builder: (controller) => Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: Palette.black2,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                hintText: 'Send a message...',
                hintStyle:
                    TextStyle(color: Get.theme.primaryColor.withOpacity(0.4)),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: controller.showAttachOptions
                  ? Palette.black3
                  : Palette.black2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: controller.showAttachOptions
                  ? [
                      SizedBox(width: 4),
                      OpacityFeedback(
                        child: Icon(FluentIcons.image_20_regular, size: 20),
                        onPressed: () {},
                      ),
                      SizedBox(width: 14),
                      OpacityFeedback(
                        child: Icon(FluentIcons.camera_20_regular, size: 20),
                        onPressed: () {},
                      ),
                      SizedBox(width: 14),
                      OpacityFeedback(
                        child: Icon(FluentIcons.document_20_regular, size: 20),
                        onPressed: () {},
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 1,
                        height: 28,
                        color: Get.theme.primaryColor.withOpacity(0.1),
                      ),
                      SizedBox(width: 14),
                      OpacityFeedback(
                        child: Icon(
                          FluentIcons.dismiss_20_regular,
                          size: 20,
                        ),
                        onPressed: controller.toggleShowAttachOptions,
                      ),
                    ]
                  : [
                      controller.textController.text.isEmpty
                          ? OpacityFeedback(
                              child: Icon(
                                FluentIcons.attach_20_regular,
                                size: 20,
                              ),
                              onPressed: controller.toggleShowAttachOptions,
                            )
                          : OpacityFeedback(
                              child: Icon(
                                FluentIcons.send_20_regular,
                                size: 20,
                              ),
                              onPressed: controller.sendMessage,
                            ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

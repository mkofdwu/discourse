import 'package:discourse/models/replied_message.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/views/chat/dumb_widgets/is_typing_controller.dart';
import 'package:get/get.dart';

import 'message_field_controller.dart';

class MessageFieldView extends StatelessWidget {
  const MessageFieldView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageFieldController>(builder: _builder);
  }

  Widget _builder(MessageFieldController controller) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (controller.hasRepliedMessage)
            _buildRepliedMessage(controller.repliedMessage!),
          if (controller.hasRepliedMessage) _buildDivider(),
          if (controller.hasPhoto) _buildPhoto(controller.photo!),
          if (controller.hasPhoto) _buildDivider(),
          Row(
            children: [
              Expanded(
                child: GetBuilder<IsTypingController>(
                  builder: (typingNotifierController) => TextField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Message...',
                    ),
                    onChanged: (_) => typingNotifierController.onTyping(),
                  ),
                ),
              ),
              SizedBox(width: 14),
              if (controller.hasText)
                GestureDetector(
                  onTap: controller.sendMessage,
                  child: Icon(FluentIcons.send_20_regular),
                )
              else if (!controller.hasPhoto)
                Row(
                  children: [
                    GestureDetector(
                      onTap: controller.takePhotoFromCamera,
                      child: Icon(FluentIcons.camera_20_regular),
                    ),
                    SizedBox(width: 14),
                    GestureDetector(
                      onTap: controller.selectPhoto,
                      child: Icon(FluentIcons.image_20_regular),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepliedMessage(RepliedMessage repliedMessage) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(repliedMessage.text ?? 'photo'),
      );

  Widget _buildPhoto(Photo photo) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 2),
                image: DecorationImage(
                  image: FileImage(photo.file!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: 14,
            ),
            Text(photo.file!.path),
            Spacer(),
          ],
        ),
      );

  Widget _buildDivider() => Container(
        width: double.infinity,
        height: 1,
        margin: const EdgeInsets.only(bottom: 16),
        color: Palette.light0,
      );
}

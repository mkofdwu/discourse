import 'package:discourse/constants/palette.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/controllers/message_list.dart';
import 'package:discourse/views/chat/widgets/participants_typing.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TypingIndicatorAndGoToBottomArrow extends StatelessWidget {
  ChatController get controller => Get.find();
  MessageListController get messageListController => Get.find();

  const TypingIndicatorAndGoToBottomArrow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 16),
        StreamBuilder<String?>(
          stream: controller.typingTextStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            return TypingIndicator(text: snapshot.data!);
          },
        ),
        Spacer(),
        _buildScrollToBottomArrow(),
      ],
    );
  }

  Widget _buildScrollToBottomArrow() {
    return Obx(
      () => AnimatedScale(
        scale: messageListController.showGoToBottomArrow.value ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: messageListController.scrollToBottom,
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.only(top: 6, right: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF606060),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Icon(
                  FluentIcons.chevron_double_down_16_regular,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              if (messageListController.numNewMessages > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Palette.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        messageListController.numNewMessages.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

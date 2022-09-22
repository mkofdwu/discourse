import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatAppBar extends StatelessWidget {
  ChatController get controller => Get.find();

  const ChatAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Get.theme.primaryColorLight,
        child: Row(
          children: [
            MyIconButton(
              FluentIcons.chevron_left_24_regular,
              onPressed: Get.back,
            ),
            SizedBox(width: 4),
            Expanded(child: _appBarContent(controller)),
            MyIconButton(
              FluentIcons.more_vertical_24_regular,
              onPressed: controller.showChatOptions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBarContent(ChatController controller) {
    return OpacityFeedback(
      onPressed: controller.toChatDetails,
      child: Row(
        children: [
          Obx(
            () => PhotoOrIcon(
              photoUrl: controller.chat.photoUrl.value,
              placeholderIcon: controller.isPrivateChat
                  ? FluentIcons.person_16_regular
                  : FluentIcons.people_community_16_regular,
              hero: true,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.chat.title.value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 4),
                StreamBuilder<String?>(
                  stream: controller.chat.subtitle,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? '',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/views/chat/controllers/message_selection.dart';
import 'package:discourse/views/chat/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/utils/show_private_chat_options.dart';
import 'package:discourse/views/chat/widgets/deleted_message_view.dart';
import 'package:discourse/views/chat/widgets/message_draft_view.dart';
import 'package:discourse/views/chat/widgets/message_view.dart';
import 'package:discourse/views/chat/widgets/participants_typing.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_controller.dart';

class ChatView extends StatelessWidget {
  final UserChat chat;

  const ChatView({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put<UserChat>(chat); // current chat
    Get.put<MessageSenderController>(MessageSenderController());
    Get.put<MessageSelectionController>(MessageSelectionController());
    return GetBuilder<ChatController>(
      global: false,
      init: ChatController(chat),
      builder: (controller) => Obx(
        () => Scaffold(
          appBar: controller.isSelectingMessages
              ? _buildMessageSelectionAppBar(controller)
              : _buildAppBar(controller),
          body: Column(
            children: [
              Expanded(
                child: chat is NonExistentChat
                    ? SizedBox()
                    : Stack(
                        children: [
                          _buildMessagesList(controller),
                          if (!controller.isSelectingMessages)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 80,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Get.theme.scaffoldBackgroundColor,
                                      Get.theme.scaffoldBackgroundColor
                                          .withOpacity(0),
                                    ],
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(width: 16),
                                    _buildTypingIndicator(controller),
                                    Spacer(),
                                    if (controller.showGoToBottomArrow)
                                      _buildScrollToBottomArrow(controller),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              if (!controller.isSelectingMessages)
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 28, 30, 36),
                  child: MessageDraftView(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatController controller) => ListView.separated(
        padding: const EdgeInsets.only(top: 40, bottom: 100),
        reverse: true,
        controller: controller.scrollController,
        itemCount: controller.messages.length,
        itemBuilder: (context, i) {
          final message = controller.messages[i];
          if (message.isDeleted) return DeletedMessageView(message: message);
          return MessageView(
            key: controller.messageKey(message.id),
            message: message,
          );
        },
        separatorBuilder: (context, i) {
          if (controller.isPrivateChat) return SizedBox.shrink();
          final prevMessage = controller.messages[i + 1]; // list is reversed
          final nextMessage = controller.messages[i];
          if (prevMessage.sender != nextMessage.sender && !nextMessage.fromMe) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, left: 30, bottom: 8),
              child:
                  _buildSenderDetails(controller.member(nextMessage.sender.id)),
            );
          }
          return SizedBox.shrink();
        },
      );

  Widget _buildSenderDetails(Member member) => Row(
        children: [
          PhotoOrIcon(
            size: 32,
            photoUrl: member.user.photoUrl,
            placeholderIcon: FluentIcons.person_16_regular,
          ),
          SizedBox(width: 16),
          Text(
            member.user.username,
            style: TextStyle(color: member.color, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 16),
          // just for example
          if (member.role == MemberRole.admin)
            Container(
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: member.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(),
            )
        ],
      );

  PreferredSizeWidget _buildAppBar(ChatController controller) => PreferredSize(
        preferredSize: Size.fromHeight(76),
        child: SafeArea(
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Get.theme.primaryColorLight,
            child: Row(
              children: [
                OpacityFeedback(
                  child: Icon(FluentIcons.chevron_left_20_regular),
                  onPressed: () => Get.back(),
                ),
                SizedBox(width: 20),
                Expanded(child: _appBarContent(controller)),
                OpacityFeedback(
                  child: Icon(FluentIcons.more_vertical_24_regular),
                  onPressed: showPrivateChatOptions,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _appBarContent(ChatController controller) => OpacityFeedback(
        onPressed: controller.goToChatDetails,
        child: Row(
          children: [
            PhotoOrIcon(
              photoUrl: chat.photoUrl,
              placeholderIcon: chat is UserPrivateChat
                  ? FluentIcons.person_16_regular
                  : FluentIcons.people_community_16_regular,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.title,
                    style: chat.subtitle != null
                        ? TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
                        : TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  if (chat.subtitle != null) SizedBox(height: 4),
                  if (chat.subtitle != null)
                    Text(
                      chat.subtitle!,
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  PreferredSizeWidget _buildMessageSelectionAppBar(ChatController controller) =>
      PreferredSize(
        preferredSize: Size.fromHeight(76),
        child: SafeArea(
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            color: Get.theme.primaryColorLight,
            child: Row(
              children: [
                Text(
                  '${controller.numMessagesSelected} selected',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Spacer(),
                if (controller.canReplyToSelectedMessages)
                  OpacityFeedback(
                    onPressed: controller.replyToSelectedMessages,
                    child: Icon(FluentIcons.arrow_reply_20_regular, size: 20),
                  ),
                if (controller.canReplyToSelectedMessages) SizedBox(width: 16),
                if (controller.canDeleteSelectedMessages)
                  OpacityFeedback(
                    onPressed: controller.deleteSelectedMessages,
                    child: Icon(FluentIcons.delete_20_regular, size: 20),
                  ),
                if (controller.canDeleteSelectedMessages) SizedBox(width: 16),
                OpacityFeedback(
                  onPressed: controller.cancelMessageSelection,
                  child: Icon(FluentIcons.dismiss_20_regular, size: 20),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTypingIndicator(ChatController controller) =>
      StreamBuilder<String?>(
        stream: controller.typingTextStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return TypingIndicator(text: snapshot.data!);
        },
      );

  Widget _buildScrollToBottomArrow(ChatController controller) =>
      GestureDetector(
        onTap: controller.scrollToBottom,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF404040),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Icon(
            FluentIcons.chevron_double_down_16_regular,
            size: 16,
            color: Colors.white,
          ),
        ),
      );
}

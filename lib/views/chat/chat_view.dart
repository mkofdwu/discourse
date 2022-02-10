import 'package:discourse/constants/palette.dart';
import 'package:discourse/utils/format_date_time.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/chat/widgets/deleted_message_view.dart';
import 'package:discourse/views/chat/widgets/message_draft_view.dart';
import 'package:discourse/views/chat/widgets/message_view.dart';
import 'package:discourse/views/chat/widgets/participants_typing.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/app_state_handler.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/thomas_scroll.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_controller.dart';
import 'controllers/message_list.dart';
import 'controllers/message_selection.dart';
import 'controllers/message_sender.dart';

class ChatView extends StatelessWidget {
  final UserChat chat;

  const ChatView({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put<UserChat>(chat); // current chat
    Get.put<MessageSenderController>(MessageSenderController());
    Get.put<MessageSelectionController>(MessageSelectionController());
    Get.put<MessageListController>(MessageListController());
    return GetBuilder<ChatController>(
      // global: false, <- should not be here
      init: ChatController(chat),
      builder: (controller) => Obx(
        () => AppStateHandler(
          onStart: controller.onStartReading,
          onExit: controller.onStopReading,
          child: Scaffold(
            appBar: controller.messageSelection.isSelecting
                ? _buildMessageSelectionAppBar(controller)
                : _buildAppBar(controller),
            body: Column(
              children: [
                Expanded(
                  child: chat is NonExistentChat
                      ? SizedBox()
                      : GetBuilder<MessageListController>(
                          builder: (messageListController) => Stack(
                                children: [
                                  _buildMessagesList(
                                      controller, messageListController),
                                  if (!controller.messageSelection.isSelecting)
                                    _buildMessagesListBottom(
                                        controller, messageListController),
                                ],
                              )),
                ),
                if (!controller.messageSelection.isSelecting)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                    child: MessageDraftView(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatController controller,
          MessageListController messageListController) =>
      ReverseThomasScroll(
        list: messageListController.messages,
        scrollController: messageListController.scrollController,
        itemBuilder: (context, i) {
          final message = messageListController.messages[i];
          final messageWidget = message.isDeleted
              ? DeletedMessageView(message: message)
              : MessageView(
                  key: messageListController.messageKey(message.id),
                  message: message,
                  isHighlighted: message.id == controller.highlightedMessageId,
                );
          if (i - 1 < 0) {
            return messageWidget;
          }

          final prevMessage = messageListController.messages[i - 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSameDay(
                prevMessage.sentTimestamp,
                message.sentTimestamp,
              )) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 60, 40, 20),
                  child: OpacityFeedback(
                    onPressed: controller.toSelectDate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(message.sentTimestamp),
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _dayOfWeek(message.sentTimestamp),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                ),
                SizedBox(height: 32),
              ],
              if (!controller.isPrivateChat &&
                  prevMessage.sender != message.sender &&
                  !message.fromMe)
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30, bottom: 8),
                  child: _buildSenderDetails(controller.member(message.sender)),
                ),
              messageWidget,
            ],
          );
        },
      );

  Widget _buildMessagesListBottom(
    ChatController controller,
    MessageListController messageListController,
  ) =>
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
                Get.theme.scaffoldBackgroundColor.withOpacity(0),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 16),
              _buildTypingIndicator(controller),
              Spacer(),
              if (messageListController.showGoToBottomArrow)
                _buildScrollToBottomArrow(controller, messageListController),
            ],
          ),
        ),
      );

  String _formatDate(DateTime date) {
    if (isSameDay(date, DateTime.now())) return 'Today';
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${monthNames[date.month - 1]}';
  }

  String _dayOfWeek(DateTime date) {
    const weekdayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdayNames[date.weekday - 1];
  }

  Widget _buildSenderDetails(Member member) => Row(
        children: [
          PhotoOrIcon(
            size: 32,
            photoUrl: member.user.photoUrl,
            placeholderIcon: member.role == MemberRole.removed
                ? FluentIcons.delete_16_regular
                : FluentIcons.person_16_regular,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Get.theme.primaryColorLight,
            child: Row(
              children: [
                MyIconButton(
                  FluentIcons.chevron_left_24_regular,
                  onPressed: () => Get.back(),
                ),
                SizedBox(width: 12),
                Expanded(child: _appBarContent(controller)),
                MyIconButton(
                  FluentIcons.more_vertical_24_regular,
                  onPressed: controller.showChatOptions,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _appBarContent(ChatController controller) => OpacityFeedback(
        onPressed: controller.toChatDetails,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  StreamBuilder<String?>(
                    stream: chat.subtitle,
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

  PreferredSizeWidget _buildMessageSelectionAppBar(ChatController controller) =>
      myAppBar(
        title: '${controller.messageSelection.numSelected} selected',
        onBack: controller.messageSelection.cancelMessageSelection,
        actions: {
          if (controller.messageSelection.canReplyToSelectedMessages)
            FluentIcons.arrow_reply_20_regular:
                controller.messageSelection.replyToSelectedMessages,
          if (controller.messageSelection.canDeleteSelectedMessages)
            FluentIcons.delete_20_regular:
                controller.messageSelection.deleteSelectedMessages,
          if (controller.messageSelection.canGoToViewedBy)
            FluentIcons.eye_show_20_regular: controller.toMessageViewedBy,
        },
      );

  Widget _buildTypingIndicator(ChatController controller) =>
      StreamBuilder<String?>(
        stream: controller.typingTextStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return TypingIndicator(text: snapshot.data!);
        },
      );

  Widget _buildScrollToBottomArrow(
    ChatController controller,
    MessageListController messageListController,
  ) =>
      GestureDetector(
        onTap: messageListController.scrollToBottom,
        child: Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              margin: EdgeInsets.only(top: 8, right: 6),
              decoration: BoxDecoration(
                color: Color(0xFF404040),
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
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Palette.orange,
                    borderRadius: BorderRadius.circular(12),
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
      );
}

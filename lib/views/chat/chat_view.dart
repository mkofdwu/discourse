import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/chat_alert.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/chat/widgets/deleted_message_view.dart';
import 'package:discourse/views/chat/widgets/message_draft_view.dart';
import 'package:discourse/views/chat/widgets/message_view.dart';
import 'package:discourse/views/chat/widgets/participants_typing.dart';
import 'package:discourse/views/chat/widgets/spotify_message_view.dart';
import 'package:discourse/widgets/app_state_handler.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/selection_options_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';

import 'chat_controller.dart';
import 'controllers/message_list.dart';
import 'controllers/message_selection.dart';
import 'controllers/message_sender.dart';

class ChatView extends StatefulWidget {
  final UserChat chat;

  const ChatView({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  MessageListController get messageListController =>
      Get.find<MessageListController>();

  @override
  void initState() {
    super.initState();
    Get.put(MessageSenderController());
    Get.put(MessageSelectionController());
    Get.put(ChatController(widget.chat));
    Get.put(MessageListController());
  }

  @override
  void dispose() {
    Get.delete<MessageListController>();
    Get.delete<ChatController>();
    Get.delete<MessageSelectionController>();
    Get.delete<MessageSenderController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (controller) => AppStateHandler(
        onStart: controller.onStartReading,
        onExit: controller.onStopReading,
        child: Material(
          child: Stack(
            children: [
              Scaffold(
                appBar: _buildAppBar(controller),
                body: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          GetBuilder<MessageListController>(
                            builder: (messageListController) =>
                                _buildMessagesList(
                                    controller, messageListController),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            // for some mysterious reason flutter sometimes adds 1px spacing at the bottom
                            bottom: -1,
                            child: IgnorePointer(
                              child: Container(
                                height: 80,
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
                                    const EdgeInsets.symmetric(horizontal: 24),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 0,
                            child: _buildMessagesListBottom(controller),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: controller.messageSelection.isSelecting ? 0 : 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: MessageDraftView(),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => SelectionOptionsBar(
                  numSelected: controller.messageSelection.numSelected,
                  options: {
                    if (controller.messageSelection.canReplyToSelectedMessages)
                      FluentIcons.arrow_reply_24_regular:
                          controller.messageSelection.replyToSelectedMessages,
                    if (controller.messageSelection.canDeleteSelectedMessages)
                      FluentIcons.delete_24_regular:
                          controller.messageSelection.deleteSelectedMessages,
                    if (controller.messageSelection.canGoToViewedBy)
                      FluentIcons.eye_24_regular: controller.toMessageViewedBy
                  },
                  onDismiss: controller.messageSelection.cancelSelection,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(
    ChatController controller,
    MessageListController messageListController,
  ) =>
      Obx(
        () => FlutterListView(
          reverse: true,
          controller: messageListController.listController,
          delegate: FlutterListViewDelegate(
            (context, i) {
              final chatObject = messageListController.chatLog[i];
              final prevObject = i + 1 >= messageListController.chatLog.length
                  ? null
                  : messageListController.chatLog[i + 1];
              final nextObject =
                  i - 1 < 0 ? null : messageListController.chatLog[i - 1];
              final showDate =
                  (prevObject == null && messageListController.reachedTop) ||
                      (prevObject != null &&
                          !isSameDay(
                            prevObject.sentTimestamp,
                            chatObject.sentTimestamp,
                          ));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDate) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 60, 32, 20),
                      child: OpacityFeedback(
                        onPressed: messageListController.toSelectDate,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(chatObject.sentTimestamp),
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _dayOfWeek(chatObject.sentTimestamp),
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
                  chatObject is Message
                      ? _buildMessage(controller, messageListController,
                          chatObject, prevObject)
                      : _buildChatAlert(chatObject.asChatAlert, prevObject,
                          nextObject, showDate),
                  if (i == 0) SizedBox(height: 80),
                ],
              );
            },
            childCount: messageListController.chatLog.length,
            onItemKey: (i) => messageListController.chatLog[i].id,
          ),
        ),
      );

  Widget _buildMessage(
    ChatController controller,
    MessageListController messageListController,
    Message message,
    ChatLogObject? prevObject,
  ) {
    final messageWidget = message.isDeleted
        ? DeletedMessageView(message: message)
        : message.text?.startsWith('https://open.spotify.com/track/') ?? false
            ? SpotifyMessageView(message: message)
            : MessageView(message: message);
    if (prevObject == null) return messageWidget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!controller.isPrivateChat &&
            (prevObject is! Message || prevObject.sender != message.sender) &&
            !message.fromMe)
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 30, bottom: 8),
            child: _buildSenderDetails(controller.member(message.sender)),
          ),
        messageWidget,
      ],
    );
  }

  Widget _buildChatAlert(
    ChatAlert alert,
    ChatLogObject? prevObject,
    ChatLogObject? nextObject,
    bool showDate,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: prevObject is ChatAlert || showDate ? 0 : 24,
        bottom: nextObject is ChatAlert ? 12 : 24,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: Palette.black3,
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Avenir',
                color: Colors.white.withOpacity(0.6),
              ),
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      _chatActionIcon(alert.action),
                      color: Colors.white.withOpacity(0.6),
                      size: 14,
                    ),
                  ),
                ),
                TextSpan(text: alert.content, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _chatActionIcon(ChatAction action) {
    switch (action) {
      case ChatAction.editName:
      case ChatAction.editDescription:
        return FluentIcons.edit_16_filled;
      case ChatAction.editPhoto:
        return FluentIcons.image_edit_16_filled;
      case ChatAction.addMember:
      case ChatAction.memberJoin:
        return FluentIcons.person_add_16_filled;
      case ChatAction.removeMember:
      case ChatAction.memberLeave:
        return FluentIcons.person_delete_16_filled;
      case ChatAction.addAdmin:
        return FluentIcons.arrow_up_16_filled;
      case ChatAction.removeAdmin:
        return FluentIcons.arrow_down_16_filled;
      case ChatAction.transferOwnership:
        return FluentIcons.arrow_swap_20_filled;
    }
  }

  Widget _buildMessagesListBottom(ChatController controller) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 16),
          _buildTypingIndicator(controller),
          Spacer(),
          Obx(
            () => AnimatedScale(
              scale: messageListController.showGoToBottomArrow.value ? 1 : 0,
              duration: Duration(milliseconds: 200),
              child:
                  _buildScrollToBottomArrow(controller, messageListController),
            ),
          ),
        ],
      );

  String _formatDate(DateTime date) {
    if (isToday(date)) return 'Today';
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
        ),
      );

  Widget _appBarContent(ChatController controller) => OpacityFeedback(
        onPressed: controller.toChatDetails,
        child: Row(
          children: [
            Obx(
              () => PhotoOrIcon(
                photoUrl: widget.chat.photoUrl.value,
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
                      widget.chat.title.value,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 4),
                  StreamBuilder<String?>(
                    stream: widget.chat.subtitle,
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
      );
}

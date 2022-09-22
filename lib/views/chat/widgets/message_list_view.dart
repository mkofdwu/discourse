import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/chat_alert.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/controllers/message_list.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';

import 'deleted_message_view.dart';
import 'message_view.dart';
import 'spotify_message_view.dart';

class MessageListView extends StatelessWidget {
  ChatController get chatController => Get.find();

  const MessageListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageListController>(
      builder: (controller) {
        return Obx(
          () => FlutterListView(
            reverse: true,
            controller: controller.listController,
            delegate: FlutterListViewDelegate(
              (context, i) => _listItemBuilder(controller, i),
              childCount: controller.chatLog.length,
              onItemKey: (i) => controller.chatLog[i].id,
            ),
          ),
        );
      },
    );
  }

  Widget _listItemBuilder(MessageListController controller, int i) {
    final chatObject = controller.chatLog[i];
    final prevObject =
        i + 1 >= controller.chatLog.length ? null : controller.chatLog[i + 1];
    final nextObject = i - 1 < 0 ? null : controller.chatLog[i - 1];
    final showDate = (prevObject == null && controller.reachedTop) ||
        (prevObject != null &&
            !isSameDay(
              prevObject.sentTimestamp,
              chatObject.sentTimestamp,
            ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDate) ..._buildDateInColumn(controller, chatObject),
        chatObject is Message
            ? _buildMessage(controller, chatObject, prevObject)
            : _buildChatAlert(
                chatObject.asChatAlert, prevObject, nextObject, showDate),
        if (i == 0) SizedBox(height: 80),
      ],
    );
  }

  List<Widget> _buildDateInColumn(
    MessageListController controller,
    ChatLogObject chatObject,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 20),
        child: OpacityFeedback(
          onPressed: controller.toSelectDate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(chatObject.sentTimestamp),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
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
    ];
  }

  Widget _buildMessage(
    MessageListController controller,
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
        if (!chatController.isPrivateChat &&
            (prevObject is! Message || prevObject.sender != message.sender) &&
            !message.fromMe)
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 30, bottom: 8),
            child: _buildSenderDetails(chatController.member(message.sender)),
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

  Widget _buildSenderDetails(Member member) {
    return Row(
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
          ),
      ],
    );
  }

  // utils

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
}

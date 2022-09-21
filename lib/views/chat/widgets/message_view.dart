import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/utils/url.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/controllers/message_list.dart';
import 'package:discourse/views/chat/controllers/message_selection.dart';
import 'package:discourse/views/chat/controllers/message_sender.dart';
import 'package:discourse/views/chat/widgets/reply_gesture.dart';
import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MessageView extends StatefulWidget {
  final Message message;

  const MessageView({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final _messageSender = Get.find<MessageSenderController>();
  final _messageSelection = Get.find<MessageSelectionController>();
  final _chatController = Get.find<ChatController>(); // for highlighted message

  bool get _isSelected =>
      _messageSelection.selectedMessages.contains(widget.message);
  bool get _isHighlighted =>
      _chatController.highlightedMessageId.value == widget.message.id;

  void onTap() {
    if (_messageSelection.isSelecting) {
      toggleSelectMessage();
    }
  }

  void viewPhoto() {
    if (widget.message.photo != null) {
      Get.to(
        () => ExaminePhotoView(
          photo: widget.message.photo!,
          caption: widget.message.text,
          // prevent hero transition between chat view and user profile view / group details view
          heroTag: 'MessageView:${widget.message.photo!.heroTag}',
        ),
        transition: Transition.fadeIn,
      );
    }
  }

  void scrollToRepliedMessage(RepliedMessage message) async {
    await Get.find<MessageListController>().scrollToMessage(message.id);
    Get.find<ChatController>().highlightMessage(message.id);
  }

  void replyToThis() {
    _messageSender.repliedMessage.value = widget.message.asRepliedMessage();
  }

  void toggleSelectMessage() {
    _messageSelection.toggleSelectMessage(widget.message);
  }

  Color getRepliedMessageColor() {
    final currentChat = Get.find<ChatController>().chat;
    if (currentChat is UserPrivateChat) return Palette.orange;
    currentChat as UserGroupChat;
    final repliedMessageSender = currentChat.groupData.members.firstWhere(
        (m) => m.user.id == widget.message.repliedMessage!.sender.id);
    return repliedMessageSender.color;
  }

  @override
  Widget build(BuildContext context) {
    return ReplyGesture(
      onReply: replyToThis,
      accountForWidth: !widget.message.fromMe,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: toggleSelectMessage,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            mainAxisAlignment: widget.message.fromMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 240),
                    margin: EdgeInsets.only(
                      left: widget.message.fromMe ? 12 : 0,
                      right: widget.message.fromMe ? 0 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: widget.message.fromMe
                          ? Palette.orange
                          : Get.theme.primaryColorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias, // image circular borders
                    child: Column(
                      children: [
                        if (widget.message.photo != null)
                          _buildPhotoView(widget.message.photo!),
                        SizedBox(
                          width: widget.message.photo != null ? 240 : null,
                          child: IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.message.repliedMessage != null)
                                  _buildRepliedMessageView(
                                    widget.message.repliedMessage!,
                                    getRepliedMessageColor(),
                                  ),
                                _buildFancyTextAndTimestampWrap(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    left: widget.message.fromMe ? 12 : 0,
                    right: widget.message.fromMe ? 0 : 12,
                    child: Obx(
                      () => IgnorePointer(
                        // if not ignoring, you cant click to view photo or go to replied message
                        ignoring: !_messageSelection.isSelecting,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 200),
                          opacity: _isSelected || _isHighlighted ? 1 : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.message.fromMe ? 0 : null,
                    right: widget.message.fromMe ? null : 0,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Obx(
                        () => AnimatedScale(
                          duration: Duration(milliseconds: 200),
                          scale: _isSelected ? 1 : 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                FluentIcons.checkmark_12_filled,
                                color: Colors.black,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoView(Photo photo) => GestureDetector(
        onTap: viewPhoto,
        child: Hero(
          tag: 'MessageView:${photo.heroTag}',
          child: CachedNetworkImage(imageUrl: photo.url!, width: 240),
        ),
      );

  Widget _buildRepliedMessageView(RepliedMessage repliedMessage, Color color) =>
      PressedBuilder(
        onPressed: () => scrollToRepliedMessage(repliedMessage),
        builder: (pressed) => Container(
          color: pressed ? Colors.black.withOpacity(0.08) : null,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.rotate(
                  angle: pi,
                  child: Icon(FluentIcons.text_quote_20_filled, size: 20),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Opacity(
                    opacity: 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repliedMessage.sender.username,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          repliedMessage.isDeleted
                              ? 'Deleted message'
                              : repliedMessage.reprContent,
                          style: TextStyle(fontSize: 12),
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

  Widget _buildFancyTextAndTimestampWrap() {
    final textSpans = <TextSpan>[];
    if (widget.message.text != null) {
      int prev = 0;
      for (final match in urlRegex.allMatches(widget.message.text!)) {
        final text = widget.message.text!.substring(prev, match.start);
        final url = match.group(0)!;
        final fullUrl =
            url.startsWith(RegExp(r'https?://')) ? url : 'https://$url';
        textSpans.add(TextSpan(text: text));
        textSpans.add(TextSpan(
          text: url,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrlString(fullUrl, mode: LaunchMode.externalApplication);
            },
        ));
        prev = match.end;
      }
      if (prev == 0) {
        // no links in message
        textSpans.add(TextSpan(text: '${widget.message.text!}  '));
      } else {
        // add remaining text
        textSpans.add(TextSpan(
          text: '${widget.message.text!.substring(prev)}  ',
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w500,
              ),
              children: [
                ...textSpans,
                TextSpan(
                  text: formatTime(widget.message.sentTimestamp),
                  style: TextStyle(
                    color: Colors.transparent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              formatTime(widget.message.sentTimestamp),
              style: TextStyle(
                color: Get.theme.primaryColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/views/chat/controllers/is_typing_controller.dart';
import 'package:discourse/views/chat/controllers/message_sender.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'message_draft_controller.dart';

class MessageDraftView extends StatefulWidget {
  const MessageDraftView({Key? key}) : super(key: key);

  @override
  State<MessageDraftView> createState() => _MessageDraftViewState();
}

class _MessageDraftViewState extends State<MessageDraftView> {
  Widget _replyPreview = SizedBox();
  Widget _photoPreview = SizedBox();

  MessageDraftController get controller => Get.find<MessageDraftController>();
  StreamSubscription? _repliedMessageSubscription;
  StreamSubscription? _photoSubscription;

  void _repliedMessageListener(RepliedMessage? replyTo) {
    if (replyTo == null) {
      setState(() {
        _replyPreview = SizedBox();
      });
    } else {
      setState(() {
        _replyPreview = Column(
          key: UniqueKey(),
          children: [
            SizedBox(height: 4),
            Dismissible(
              key: ValueKey(replyTo.id),
              // resizing will be done when switched out to sizedbox
              // allowing dismissible to resize means there will be
              // undesirable resize twice (once for the preview and once
              // for the divider)
              resizeDuration: Duration(hours: 1),
              confirmDismiss: (direction) async {
                controller.removeReply();
                return true;
              },
              child: _buildReplyPreview(
                replyTo,
                controller.removeReply,
              ),
            ),
            _buildDivider(),
          ],
        );
      });
    }
  }

  void _photoListener(Photo? photo) {
    if (photo == null) {
      setState(() {
        _photoPreview = SizedBox();
      });
    } else {
      setState(() {
        _photoPreview = Column(
          key: UniqueKey(),
          children: [
            SizedBox(height: 4),
            Dismissible(
              key: UniqueKey(),
              resizeDuration: Duration(hours: 1),
              confirmDismiss: (direction) async {
                controller.removePhoto();
                return true;
              },
              child: _buildPhotoPreview(
                photo,
                controller.removePhoto,
              ),
            ),
            _buildDivider(),
          ],
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _repliedMessageSubscription = Get.find<MessageSenderController>()
        .repliedMessage
        .listen(_repliedMessageListener);
    _photoSubscription =
        Get.find<MessageSenderController>().photo.listen(_photoListener);
  }

  @override
  void dispose() {
    _repliedMessageSubscription?.cancel();
    _photoSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageDraftController>(
      init: MessageDraftController(),
      builder: (controller) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildMain(),
            ),
            SizedBox(width: 12),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Palette.black2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: controller.showAttachOptions
                  ? OpacityFeedback(
                      onPressed: controller.toggleShowAttachOptions,
                      child: Icon(
                        FluentIcons.dismiss_20_regular,
                        size: 20,
                      ),
                    )
                  : controller.hasText || controller.hasPhoto
                      ? OpacityFeedback(
                          onPressed: controller.sendMessage,
                          child: Icon(
                            FluentIcons.send_20_regular,
                            size: 20,
                          ),
                        )
                      : OpacityFeedback(
                          onPressed: controller.toggleShowAttachOptions,
                          child: Icon(
                            FluentIcons.attach_20_regular,
                            size: 20,
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMain() => Container(
        decoration: BoxDecoration(
          color: Palette.black2,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: _replyPreview,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: _photoPreview,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: child is Row ? Offset(0, 1) : Offset(0, -1),
                      end: child is Row ? Offset(0, 0) : Offset(0, 0),
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: controller.showAttachOptions
                  ? _buildAttachOptions()
                  : GetBuilder<IsTypingController>(
                      global: false,
                      init: IsTypingController(),
                      builder: (isTypingController) => TextField(
                        controller: controller.textController,
                        onChanged: (_) => isTypingController.onTyping(),
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: InputBorder.none,
                          hintText: 'Send a message...',
                          hintStyle: TextStyle(
                            color: Get.theme.primaryColor.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );

  Widget _buildDivider() => Container(
        width: double.infinity,
        height: 1,
        color: Get.theme.primaryColor.withOpacity(0.06),
        margin: const EdgeInsets.only(top: 14, bottom: 10),
      );

  Widget _buildReplyPreview(RepliedMessage replyTo, Function() removeReply) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFF363636),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(FluentIcons.arrow_reply_16_regular, size: 16),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  replyTo.sender.username,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                // TEMPORARY
                Text(replyTo.text!, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          OpacityFeedback(
            onPressed: removeReply,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(FluentIcons.dismiss_16_regular, size: 16),
            ),
          ),
        ],
      );

  Widget _buildPhotoPreview(Photo photo, Function() removePhoto) => Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: photo.isLocal
                ? FileImage(photo.file!)
                : CachedNetworkImageProvider(photo.url!) as ImageProvider,
          ),
          SizedBox(width: 18),
          Text('Attached a photo'),
          Spacer(),
          OpacityFeedback(
            onPressed: removePhoto,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(FluentIcons.dismiss_16_regular, size: 16),
            ),
          ),
        ],
      );

  Widget _buildAttachOptions() => Row(
        children: [
          _buildAttachmentOption(
            FluentIcons.image_20_regular,
            'Gallery',
            () => controller.selectPhoto(false),
          ),
          Spacer(),
          Container(
            width: 1,
            height: 25,
            color: Colors.white.withOpacity(0.1),
          ),
          Spacer(),
          _buildAttachmentOption(
            FluentIcons.camera_20_regular,
            'Camera',
            () => controller.selectPhoto(true),
          ),
          Spacer(),
          Container(
            width: 1,
            height: 25,
            color: Colors.white.withOpacity(0.1),
          ),
          Spacer(),
          _buildAttachmentOption(
            FluentIcons.link_20_regular,
            'Link',
            () {}, // TODO
          ),
        ],
      );

  Widget _buildAttachmentOption(
          IconData iconData, String name, Function() onPressed) =>
      OpacityFeedback(
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              iconData,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 2,
              ),
            ),
          ],
        ),
      );
}

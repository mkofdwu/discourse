import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/chat/widgets/app_bar.dart';
import 'package:discourse/views/chat/widgets/message_draft_view.dart';
import 'package:discourse/views/chat/widgets/message_list_view.dart';
import 'package:discourse/views/chat/widgets/typing_indicator_and_go_to_bottom_arrow.dart';
import 'package:discourse/widgets/app_state_handler.dart';
import 'package:discourse/widgets/selection_options_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
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
              _buildPage(controller),
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
                      FluentIcons.eye_24_regular: controller.toMessageViewedBy,
                    FluentIcons.arrow_forward_24_regular:
                        controller.forwardMessage,
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

  Scaffold _buildPage(ChatController controller) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(76), child: ChatAppBar()),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MessageListView(),
                Positioned(
                  left: 0,
                  right: 0,
                  // for some mysterious reason flutter sometimes adds 1px spacing at the bottom
                  bottom: -1,
                  child: _buildBottomGradient(),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 0,
                  child: TypingIndicatorAndGoToBottomArrow(),
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
    );
  }

  Widget _buildBottomGradient() {
    return IgnorePointer(
      child: Container(
        height: 80,
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
      ),
    );
  }
}

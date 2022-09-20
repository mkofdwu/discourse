import 'dart:async';

import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/date_selector/date_selector_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';

const chunkSize = 20; // load 50 messages at a time

class MessageListController extends GetxController {
  final _chatLogDb = Get.find<ChatLogDbService>();

  UserChat get _chat => Get.find<ChatController>().chat;

  final listController = FlutterListViewController();

  final chatLog = RxList<ChatLogObject>();
  bool _reachedTop = false; // whether all messages have been loaded until top
  bool _reachedBottom = false;
  StreamSubscription? _lastMessageSubscription;
  int numNewMessages =
      0; // used if user has not scrolled to bottom; this number is displayed on the scroll to bottom FAB

  RxBool showGoToBottomArrow = false.obs;

  @override
  void onReady() async {
    listController.addListener(onScroll);
    // required to specify timestamp since there are no messages yet
    await _fetchMoreMessages(true,
        timestamp: DateTime.now().add(Duration(hours: 1)));
    _reachedBottom = true;
    update();
    watchLastMessage();
  }

  @override
  void onClose() {
    listController.removeListener(onScroll);
    _lastMessageSubscription?.cancel();
  }

  Future<void> _fetchMoreMessages(bool fetchOlder,
      {DateTime? timestamp}) async {
    // this function returns true if end is reached; all messages in that direction
    // have been loaded
    // this function is not responsible for checking _reachedTop or
    // _reachedBottom
    // topOrBottom: fetch from top if true
    final moreMessages = await _chatLogDb.fetchMoreMessages(
      _chat.id,
      // timestamp is only used when loading messages for the first time
      // or when jumping to section in chat log
      timestamp ??
          (fetchOlder
              ? chatLog.last.sentTimestamp
              : chatLog.first.sentTimestamp),
      chunkSize,
      fetchOlder,
    );
    if (fetchOlder) {
      chatLog.addAll(moreMessages.reversed);
    } else {
      chatLog.insertAll(0, moreMessages.reversed);
    }
    if (fetchOlder) {
      _reachedTop = moreMessages.length < chunkSize;
    } else {
      _reachedBottom = moreMessages.length < chunkSize;
    }
    update();
  }

  void watchLastMessage() {
    if (_chat is NonExistentChat) return;
    _lastMessageSubscription =
        _chatLogDb.streamLastChatObject(_chat.id).listen((chatObject) {
      if (chatLog.isEmpty || chatObject.id != chatLog.first.id) {
        if (_reachedBottom) {
          chatLog.insert(0, chatObject);
        }
        if (showGoToBottomArrow.value) {
          numNewMessages += 1;
          update();
        }
        if (chatObject is Message && chatObject.fromMe) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom();
          });
        } else if (_reachedBottom && !showGoToBottomArrow.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            listController.animateTo(
              listController.position.minScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      }
    });
  }

  Future<void> scrollToMessage(String messageId) async {
    final index = chatLog.indexWhere((m) => m.id == messageId);
    if (index == -1) {
      // if message is so long ago that it hasn't been loaded yet
      await jumpToMessage(messageId);
    }
    await listController.sliverController.animateToIndex(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      offset: 200,
    );
  }

  Future<void> jumpToMessage(String messageId) async {
    // this method may also be called when scrolling to specific image/video/link
    // in the chat or a starred message
    chatLog.clear();
    chatLog.add(await _chatLogDb.getMessage(_chat.id, messageId));
    // then fetch messages on either side
    await _fetchMoreMessages(true);
    await _fetchMoreMessages(false);
    // TODO: scroll to message
    update();
  }

  void jumpToTimestamp(DateTime timestamp) async {
    // fetch messages on either side
    chatLog.clear();
    await _fetchMoreMessages(true, timestamp: timestamp);
    await _fetchMoreMessages(false, timestamp: timestamp);
    // TODO: scroll to correct message
    update();
  }

  void onScroll() {
    showGoToBottomArrow.value = listController.offset > 80;
    if (listController.position.atEdge) {
      if (listController.position.pixels >= 0) {
        // scrolled to the top
        if (!_reachedTop) _fetchMoreMessages(true);
      } else {
        // scrolled to the bottom
        if (!_reachedBottom) _fetchMoreMessages(false);
      }
    }
  }

  void scrollToBottom() {
    if (!_reachedBottom) {
      jumpToTimestamp(DateTime.now());
      return;
    }

    final bottom = listController.position.minScrollExtent;
    // if (listController.offset > 1000) {
    //   listController.jumpTo(bottom);
    // } else {
    listController.animateTo(
      bottom,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // }

    // this may not be completely accurate
    numNewMessages = 0;
    update();
  }

  Future<bool> showSeenIndicator() async {
    if (chatLog.last is Message && !chatLog.last.asMessage.fromMe) {
      return false;
    }
    return _chatLogDb.isViewedByAll(_chat, chatLog.last.sentTimestamp);
  }

  void toSelectDate() async {
    final date = await Get.to(() => DateSelectorView(title: 'Go to date'));
    if (date != null) {
      jumpToTimestamp(date);
    }
  }
}

import 'dart:async';

import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/date_selector/date_selector_view.dart';
import 'package:discourse/widgets/thomas_scroll.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

const chunkSize = 20; // load 50 messages at a time

class MessageListController extends GetxController {
  final _chatLogDb = Get.find<ChatLogDbService>();

  UserChat get _chat => Get.find<ChatController>().chat;

  final scrollController = ScrollController(
      initialScrollOffset: -80); // specific to customscrollview with center

  // first element is the oldest, last element is most recent message.
  final chatLog = TopBottomList<ChatLogObject>([]);
  final _messageKeys = <String, GlobalKey>{};
  bool _reachedTop = false;
  bool _reachedBottom = false;
  StreamSubscription? _lastMessageSubscription;
  int numNewMessages =
      0; // used if user has not scrolled to bottom; this number is displayed on the scroll to bottom FAB

  double get _trueOffset =>
      scrollController.position.pixels -
      scrollController.position.minScrollExtent;
  bool get showGoToBottomArrow =>
      scrollController.hasClients && _trueOffset > 80;

  @override
  void onReady() async {
    scrollController.addListener(onScroll);
    // required to specify timestamp since there are no messages yet
    await _fetchMoreMessages(true,
        timestamp: DateTime.now().add(Duration(hours: 1)));
    _reachedBottom = true;
    update();
    watchLastMessage();
  }

  @override
  void onClose() {
    _lastMessageSubscription?.cancel();
    scrollController.removeListener(onScroll);
  }

  GlobalKey messageKey(String messageId) {
    // cant use the same global key after rebuild or smth
    _messageKeys[messageId] = GlobalKey();
    return _messageKeys[messageId]!;
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
              ? chatLog.first.sentTimestamp
              : chatLog.last.sentTimestamp),
      chunkSize,
      fetchOlder,
    );
    if (fetchOlder) {
      chatLog.addAllTop(moreMessages.reversed); // adds them the correct dir
    } else {
      chatLog.addAll(moreMessages);
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
      if (chatLog.isEmpty || chatObject.id != chatLog.last.id) {
        if (_reachedBottom) {
          chatLog.add(chatObject);
        }
        if (showGoToBottomArrow) {
          numNewMessages += 1;
        }
        update();
        if (chatObject is Message && chatObject.fromMe) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom();
          });
        } else if (_reachedBottom && !showGoToBottomArrow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.animateTo(
              scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeIn,
            );
          });
        }
      }
    });
  }

  Future<void> scrollToMessage(String messageId) async {
    // sadly, this doesn't work since listview hasn't built messages that are not
    // visible yet
    // if (_messageKeys.containsKey(messageId)) {
    //   await Scrollable.ensureVisible(
    //     _messageKeys[messageId]!.currentContext!,
    //     duration: const Duration(milliseconds: 400),
    //     alignment: 0.8,
    //   );
    // } else {
    // if message is so long ago that it hasn't been loaded yet
    await jumpToMessage(messageId);
    // }
  }

  Future<void> jumpToMessage(String messageId) async {
    // this method may also be called when scrolling to specific image/video/link
    // in the chat or a starred message
    chatLog.clear();
    _messageKeys.clear();
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
    _messageKeys.clear();
    await _fetchMoreMessages(true, timestamp: timestamp);
    await _fetchMoreMessages(false, timestamp: timestamp);
    // TODO: scroll to correct message
    update();
  }

  void onScroll() {
    update(); // for scroll to bottom button display conditionally
    if (scrollController.position.atEdge) {
      // this works also without checking true offset
      if (scrollController.position.pixels >= 0) {
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

    final bottom = scrollController.position.minScrollExtent;
    if (_trueOffset > 1000) {
      scrollController.jumpTo(bottom);
    } else {
      scrollController.animateTo(
        bottom,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeIn,
      );
    }

    // this may not be completely accurate
    numNewMessages = 0;
    update();
  }

  Future<bool> showSeenIndicator() async {
    if (chatLog.last.isMessage && !chatLog.last.asMessage.fromMe) return false;
    return _chatLogDb.isViewedByAll(_chat, chatLog.last.sentTimestamp);
  }

  void toSelectDate() async {
    final date = await Get.to(() => DateSelectorView(title: 'Go to date'));
    if (date != null) {
      jumpToTimestamp(date);
    }
  }
}

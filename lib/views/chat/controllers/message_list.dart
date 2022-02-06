import 'dart:async';

import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

const CHUNK_SIZE = 40; // load 50 messages at a time

class MessageListController extends GetxController {
  final _messagesDb = Get.find<MessagesDbService>();
  final _chat = Get.find<UserChat>();

  final scrollController = ScrollController();

  // first element is the oldest, last element is most recent message.
  final messages = <Message>[];
  final _messageKeys = <String, GlobalKey>{};
  bool _reachedTop = false;
  bool _reachedBottom = false;
  StreamSubscription? _lastMessageSubscription;
  int numNewMessages =
      0; // used if user has not scrolled to bottom; this number is displayed on the scroll to bottom FAB

  bool get showGoToBottomArrow =>
      scrollController.hasClients ? scrollController.offset > 100 : false;

  @override
  void onReady() async {
    scrollController.addListener(onScroll);
    // required to specify timestamp since there are no messages yet
    await fetchMoreMessages(true,
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

  Future<void> fetchMoreMessages(bool fetchOlder, {DateTime? timestamp}) async {
    // this function returns true if end is reached; all messages in that direction
    // have been loaded
    // this function is not responsible for checking _reachedTop or
    // _reachedBottom
    // topOrBottom: fetch from top if true
    final moreMessages = await _messagesDb.fetchMoreMessages(
      _chat.id,
      // timestamp is only used when loading messages for the first time
      // or when jumping to section in chat log
      timestamp ??
          (fetchOlder
              ? messages.first.sentTimestamp
              : messages.last.sentTimestamp),
      CHUNK_SIZE,
      fetchOlder,
    );
    if (fetchOlder) {
      messages.insertAll(0, moreMessages);
    } else {
      messages.addAll(moreMessages);
    }
    if (fetchOlder) {
      _reachedTop = moreMessages.length < CHUNK_SIZE;
    } else {
      _reachedBottom = moreMessages.length < CHUNK_SIZE;
    }
    update();
  }

  void watchLastMessage() {
    if (_chat is NonExistentChat) return;
    _lastMessageSubscription =
        _messagesDb.streamMessages(_chat.id, 1).listen((msgs) {
      final lastMessage = msgs.single;
      if (messages.last.id != lastMessage.id) {
        if (_reachedBottom) {
          messages.add(lastMessage);
        } else {
          numNewMessages += 1;
        }
        update();
      }
    });
  }

  void scrollToMessage(String messageId) async {
    // TODO: fixme if message has not been scrolled to yet listview hasnt built it yet
    // so there is no context
    if (_messageKeys.containsKey(messageId)) {
      Scrollable.ensureVisible(
        _messageKeys[messageId]!.currentContext!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.8,
      );
    } else {
      // if message is so long ago that it hasn't been loaded yet
      jumpToMessage(messageId);
    }
  }

  void jumpToMessage(String messageId) async {
    // this method may also be called when scrolling to specific image/video/link
    // in the chat or a starred message
    messages.clear();
    messages.add(await _messagesDb.getMessage(_chat.id, messageId));
    // then fetch messages on either side
    await fetchMoreMessages(true);
    await fetchMoreMessages(false);
    // TODO: scroll to message
    update();
  }

  void jumpToTimestamp(DateTime timestamp) async {
    // fetch messages on either side
    messages.clear();
    await fetchMoreMessages(true, timestamp: timestamp);
    await fetchMoreMessages(false, timestamp: timestamp);
    // scroll to center
    final messageId = messages[messages.length ~/ 2].id;
    Scrollable.ensureVisible(
      _messageKeys[messageId]!.currentContext!,
      alignment: 0.8,
    );
    update();
  }

  void onScroll() {
    update(); // for scroll to bottom button display conditionally
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels == 0) {
        // scrolled to the bottom
        if (!_reachedBottom) fetchMoreMessages(false);
      } else {
        // scrolled to the top
        if (!_reachedTop) fetchMoreMessages(true);
      }
    }
  }

  void scrollToBottom() {
    // TODO: if have not reached bottom, jump there
    if (scrollController.offset > 1000) {
      scrollController.jumpTo(0);
    } else {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeIn,
      );
    }
  }
}

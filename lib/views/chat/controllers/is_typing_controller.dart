import 'dart:async';

import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/whos_typing.dart';
import 'package:get/get.dart';

class IsTypingController extends GetxController {
  // if not typing for 4 seconds the user is considered to have stopped typing
  static const timeout = 4;

  final _currentChat = Get.find<UserChat>();
  final _chatDb = Get.find<WhosTypingService>();

  bool _isTyping = false;
  Timer? _stopTypingTimer;

  void onTyping() {
    if (_currentChat is NonExistentChat) return;

    if (!_isTyping) {
      _chatDb.startTyping(_currentChat.id);
      _isTyping = true;
    }

    _stopTypingTimer?.cancel();
    _stopTypingTimer = Timer(
      Duration(seconds: timeout),
      () {
        _chatDb.stopTyping(_currentChat.id);
        _isTyping = false;
      },
    );
  }
}

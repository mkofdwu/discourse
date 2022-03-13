import 'dart:async';

import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/whos_typing.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:get/get.dart';

class IsTypingController extends GetxController {
  // if not typing for 4 seconds the user is considered to have stopped typing
  static const timeout = 4;

  UserChat get _chat => Get.find<ChatController>().chat;
  final _chatDb = Get.find<WhosTypingService>();

  bool _isTyping = false;
  Timer? _stopTypingTimer;

  void onTyping() {
    if (_chat is NonExistentChat) return;

    if (!_isTyping) {
      _chatDb.startTyping(_chat.id);
      _isTyping = true;
    }

    _stopTypingTimer?.cancel();
    _stopTypingTimer = Timer(
      Duration(seconds: timeout),
      () {
        _chatDb.stopTyping(_chat.id);
        _isTyping = false;
      },
    );
  }
}

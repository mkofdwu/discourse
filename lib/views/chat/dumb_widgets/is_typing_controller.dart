import 'dart:async';

import 'package:get/get.dart';
import 'package:discourse/services/chat_db.dart';

class IsTypingController extends GetxController {
  // if not typing for 4 seconds the user is considered to have stopped typing
  static const timeout = 4;

  final _chatDb = Get.find<ChatDbService>();

  bool _isTyping = false;
  Timer? _stopTypingTimer;

  void onTyping() {
    if (!_isTyping) {
      _chatDb.startTyping(_chatDb.currentChat!.id);
      _isTyping = true;
    }

    _stopTypingTimer?.cancel();
    _stopTypingTimer = Timer(
      Duration(seconds: timeout),
      () {
        _chatDb.stopTyping(_chatDb.currentChat!.id);
        _isTyping = false;
      },
    );
  }
}

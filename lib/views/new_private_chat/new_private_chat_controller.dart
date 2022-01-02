import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/services/chat_db.dart';

class NewPrivateChatController extends GetxController {
  final _userDb = Get.find<UserDbService>();
  final _chatDb = Get.find<ChatDbService>();

  final searchController = TextEditingController();

  List<DiscourseUser> _searchResults = [];

  List<DiscourseUser> get searchResults => _searchResults;

  @override
  void onReady() {
    searchController.addListener(() {
      refreshResults();
      update();
    });
  }

  Future<void> refreshResults() async {
    _searchResults = await _userDb.searchForUsers(searchController.text);
    update();
  }

  void clearSearch() {
    searchController.text = '';
  }

  Future<void> goToChatWith(DiscourseUser user) async {
    final userChat = await _chatDb.getChatWith(user);
    Get.off(ChatView(userChat: userChat));
  }
}

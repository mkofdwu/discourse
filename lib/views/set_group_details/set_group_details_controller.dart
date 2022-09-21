import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:discourse/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetGroupDetailsController extends GetxController {
  final _media = Get.find<MediaService>();
  final _relationships = Get.find<RelationshipsService>();
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _storage = Get.find<StorageService>();
  final _miscCache = Get.find<MiscCache>();

  final nameController = TextEditingController();
  String? nameError;
  Photo? photo;
  final sendInvitesTo = <DiscourseUser>[];
  final addMembers = <DiscourseUser>[];

  SetGroupDetailsController(List<DiscourseUser> users) {
    _sortUsers(users);
  }

  Future<void> _sortUsers(List<DiscourseUser> users) async {
    for (final user in users) {
      if (await _relationships.needToAsk(user.id, RequestType.groupInvite)) {
        sendInvitesTo.add(user);
      } else {
        addMembers.add(user);
      }
    }
    update();
  }

  Future<void> selectPhoto() async {
    final newPhoto = await _media.selectPhoto();
    if (newPhoto != null) {
      photo = newPhoto;
      update();
    }
  }

  void addFriends() {
    // copied from friendlistview
    final unselectedFriends = _miscCache.myFriends
        .where((user) => !addMembers.any((selected) => selected.id == user.id))
        .toList();
    Get.to(() => UserSelectorView(
          title: 'Add friends',
          canSelectMultiple: true,
          onlyUsers: unselectedFriends,
          onSubmit: (selectedUsers) {
            addMembers.addAll(selectedUsers);
            Get.back();
            update();
          },
        ));
  }

  void inviteMore() {
    // copied from friendlistview
    Get.to(() => UserSelectorView(
          title: 'Add members',
          canSelectMultiple: true,
          excludeUsers: _miscCache.myFriends + sendInvitesTo,
          onSubmit: (selectedUsers) {
            sendInvitesTo.addAll(selectedUsers);
            Get.back();
            update();
          },
        ));
  }

  void removeAddMember(DiscourseUser friend) {
    addMembers.remove(friend);
    update();
  }

  void removeInvite(DiscourseUser user) {
    sendInvitesTo.remove(user);
    update();
  }

  Future<void> submit() async {
    if (nameController.text.isEmpty) {
      nameError = 'Please provide a group name';
      update();
      return;
    }
    if (photo != null) {
      await _storage.uploadPhoto(photo!, 'groupphoto');
    }
    final chat = await _groupChatDb.newGroup(
      GroupChatData(
        name: nameController.text,
        description: '',
        photoUrl: photo?.url,
        // service will add member or send request accordingly
        // and add the current user as owner
        members: [],
        mediaUrls: [],
        links: [],
      ),
      sendInvitesTo,
      addMembers,
    );
    Get.off(ChatView(chat: chat));
    showSnackBar(
      type: SnackBarType.success,
      message: 'Group invites were sent to ${sendInvitesTo.length} people',
    );
  }
}

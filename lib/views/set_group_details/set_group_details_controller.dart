import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetGroupDetailsController extends GetxController {
  final _media = Get.find<MediaService>();
  final _relationships = Get.find<RelationshipsService>();
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _auth = Get.find<AuthService>();

  final nameController = TextEditingController();
  Photo? photo;
  final sendInvitesTo = <DiscourseUser>[];
  final addMembers = <DiscourseUser>[];

  SetGroupDetailsController(List<DiscourseUser> users) {
    _sortUsers(users);
  }

  Future<void> _sortUsers(List<DiscourseUser> users) async {
    for (final user in users) {
      final status = await _relationships.relationshipWithMe(user.id);
      if (_relationships.isRequestNeeded(status, RequestType.groupInvite)) {
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

  Future<void> submit() async {
    if (nameController.text.isEmpty) {
      // TODO: set error
      return;
    }
    final chat = await _groupChatDb.newGroup(GroupChatData(
      name: nameController.text,
      description: '',
      // service will add member or send request accordingly
      members: (sendInvitesTo + addMembers)
              .map((user) => Member.create(user))
              .toList() +
          [Member.create(_auth.currentUser, role: MemberRole.owner)],
    ));
    Get.off(ChatView(chat: chat));
  }
}
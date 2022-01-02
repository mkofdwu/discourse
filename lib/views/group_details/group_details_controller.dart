import 'package:discourse/services/auth.dart';
import 'package:discourse/views/add_participants/add_participants_view.dart';
import 'package:discourse/views/edit_group/edit_group_view.dart';
import 'package:discourse/widgets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:discourse/models/chat_data.dart';
import 'package:discourse/models/chat_participant.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/services/chat_db.dart';

class GroupDetailsController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _chatDb = Get.find<ChatDbService>();

  GroupChatData get groupData => _chatDb.currentChat!.groupData;
  ParticipantRole get role {
    return groupData.participants
        .singleWhere((p) => p.user == _auth.currentUser)
        .role;
  }

  void goToEditGroup() {
    Get.to(EditGroupView());
  }

  Future<void> goToAddParticipants() async {
    final users = await Get.to(
      AddParticipantsView(
          excludeUserIds:
              groupData.participants.map((p) => p.user.id).toList()),
    );
    _addParticipants(users);
  }

  Future<void> removeParticipant(Participant participant) async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Remove participant',
      subtitle: 'Are you sure you want to remove ${participant.user.username}?',
    ));
    if (confirmed) {
      final userId = participant.user.id;
      await _chatDb.removeParticipant(_chatDb.currentChat!.id, userId);
      groupData.participants.removeWhere((p) => p.user.id == userId);
      update();
    }
  }

  Future<void> toggleParticipantRole(Participant participant) async {
    final newRole = participant.role == ParticipantRole.member
        ? ParticipantRole.admin
        : ParticipantRole.member;
    final response = await Get.bottomSheet(YesNoBottomSheet(
      title: newRole == ParticipantRole.admin ? 'Make admin' : 'Remove admin',
      subtitle: newRole == ParticipantRole.admin
          ? 'Are you sure you want to make ${participant.user.username} an admin?'
          : 'Are you sure you want to revoke ${participant.user.username}\'s admin status?',
    ));
    if (response != null && response.confirmed) {
      await _chatDb.updateParticipantRole(
        _chatDb.currentChat!.id,
        groupData.participants.indexOf(participant),
        newRole,
      );
      participant.role = newRole;
      update();
    }
  }

  Future<void> _addParticipants(List<DiscourseUser> users) async {
    await _chatDb.addParticipants(
      _chatDb.currentChat!.id,
      users.map((user) => Participant.create(user)).toList(),
    );
    final newParticipants = users.map((user) => Participant.create(user));
    groupData.participants.addAll(newParticipants);
    update();
  }
}

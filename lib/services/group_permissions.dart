import 'package:discourse/models/db_objects/chat_alert.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:get/get.dart';

final memberPerms = <ChatAction>[ChatAction.memberJoin, ChatAction.memberLeave];
final adminPerms = memberPerms +
    [
      ChatAction.editTitle,
      ChatAction.editDescription,
      ChatAction.editPhoto,
      ChatAction.addMember,
      ChatAction.removeMember,
      ChatAction.addAdmin,
      ChatAction.removeAdmin,
    ];
final ownerPerms = adminPerms + [ChatAction.transferOwnership];

final permissionsForRole = <MemberRole, List<ChatAction>>{
  MemberRole.member: memberPerms,
  MemberRole.admin: adminPerms,
  MemberRole.owner: ownerPerms,
};

abstract class BaseGroupPermissionsService {
  bool hasPermission(MemberRole role, ChatAction action);
}

class GroupPermissionsService extends GetxService
    implements BaseGroupPermissionsService {
  @override
  bool hasPermission(MemberRole role, ChatAction action) {
    return permissionsForRole[role]!.contains(action);
  }
}

import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/relationships.dart';
import 'package:get/get.dart';

class SetGroupDetailsController extends GetxController {
  final _relationships = Get.find<RelationshipsService>();

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
}

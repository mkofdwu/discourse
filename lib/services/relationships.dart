import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

enum RelationshipStatus {
  // arranged in increasing order of permissions
  blocked,
  none,
  canTalk,
  friend,
  closeFriend,
}

abstract class BaseRelationshipsService {
  Future<void> setMutualRelationship(
      String otherUserId, RelationshipStatus status);
  Future<bool> needToRequestUser(String otherUserId, RequestType request);
}

class RelationshipsService extends GetxService
    implements BaseRelationshipsService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  final _auth = Get.find<AuthService>();

  @override
  Future<void> setMutualRelationship(
      String otherUserId, RelationshipStatus status) async {
    _auth.currentUser.relationships[otherUserId] = status;
    await _usersRef
        .doc(_auth.id)
        .update({'relationships.$otherUserId': status.index});
    await _usersRef
        .doc(otherUserId)
        .update({'relationships.${_auth.id}': status.index});
  }

  Future<RelationshipStatus> relationshipWithMe(String otherUserId) async {
    if (otherUserId == _auth.id) {
      // this might not be completely true and might cause problems later
      return RelationshipStatus.closeFriend;
    }
    final doc = await _usersRef.doc(otherUserId).get();
    final rsIdx = doc.data()!['relationships'][_auth.id];
    return rsIdx == null
        ? RelationshipStatus.none
        : RelationshipStatus.values[rsIdx];
  }

  bool isRequestNeeded(RelationshipStatus status, RequestType permission) {
    switch (permission) {
      case RequestType.talk:
        return status.index < RelationshipStatus.canTalk.index;
      case RequestType.friend:
        return status.index < RelationshipStatus.friend.index;
      case RequestType.groupInvite:
        return status.index < RelationshipStatus.canTalk.index;
    }
  }

  @override
  Future<bool> needToRequestUser(
    String otherUserId,
    RequestType request,
  ) async {
    final rs = await relationshipWithMe(otherUserId);
    return isRequestNeeded(rs, request);
  }
}

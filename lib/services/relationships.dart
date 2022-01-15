import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

enum RelationshipStatus {
  // arranged in increasing order of permissions
  blocked,
  rejected,
  none,
  canTalk,
  friend,
  closeFriend,
}

abstract class BaseRelationshipsService {
  RelationshipStatus myRelationshipWith(String otherUserId);
  Future<RelationshipStatus> relationshipWithMe(String otherUserId);
  void setRelationshipWith(String otherUserId, RelationshipStatus status);
}

class RelationshipsService extends GetxService
    implements BaseRelationshipsService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  final _auth = Get.find<AuthService>();

  @override
  RelationshipStatus myRelationshipWith(String otherUserId) {
    return _auth.currentUser.relationships[otherUserId] ??
        RelationshipStatus.none;
  }

  @override
  Future<RelationshipStatus> relationshipWithMe(String otherUserId) async {
    final doc = await _usersRef.doc(otherUserId).get();
    final rsIdx = doc.data()!['relationships'][_auth.currentUser.id];
    return rsIdx == null
        ? RelationshipStatus.none
        : RelationshipStatus.values[rsIdx];
  }

  @override
  void setRelationshipWith(String otherUserId, RelationshipStatus status) {
    _auth.currentUser.relationships[otherUserId] = status;
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
}

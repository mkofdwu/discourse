import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

enum RelationshipStatus {
  // arranged in increasing order of permissions
  blocked,
  none,
  canTalk,
  friend,
}

abstract class BaseRelationshipsService {
  Future<void> setMutualRelationship(
      String otherUserId, RelationshipStatus status);
  Future<void> blockUser(String otherUserId);
  Future<RelationshipStatus> unblockUser(String otherUserId);
  Future<RelationshipStatus> relationshipWithMe(String otherUserId);
  Future<bool> needToAsk(String otherUserId, RequestType request);
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

  @override
  Future<void> blockUser(String otherUserId) async {
    _auth.currentUser.relationships[otherUserId] = RelationshipStatus.blocked;
    await _usersRef.doc(_auth.id).update({
      'relationships.$otherUserId': RelationshipStatus.blocked.index,
    });
  }

  @override
  Future<RelationshipStatus> unblockUser(String otherUserId) async {
    // revert to relationship other user has with me
    var rs = await relationshipWithMe(otherUserId);
    if (rs == RelationshipStatus.blocked) {
      // if other user also blocked me
      rs = RelationshipStatus.none;
    }
    _auth.currentUser.relationships[otherUserId] = rs;
    await _usersRef.doc(_auth.id).update({
      'relationships.$otherUserId': rs.index,
    });
    return rs;
  }

  @override
  Future<RelationshipStatus> relationshipWithMe(String otherUserId) async {
    if (otherUserId == _auth.id) {
      // this might not be completely true and might cause problems later
      return RelationshipStatus.friend;
    }
    final doc = await _usersRef.doc(otherUserId).get();
    final rsIdx = doc.data()!['relationships'][_auth.id];
    return rsIdx == null
        ? RelationshipStatus.none
        : RelationshipStatus.values[rsIdx];
  }

  bool _isRequestNeeded(RelationshipStatus status, RequestType permission) {
    // TODO: consider if account is public
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
  Future<bool> needToAsk(
    String otherUserId,
    RequestType request,
  ) async {
    final rs = await relationshipWithMe(otherUserId);
    return _isRequestNeeded(rs, request);
  }

  Future<List<String>> _getUsersWithRelationship(
      RelationshipStatus status) async {
    return _auth.currentUser.relationships.entries
        .where((entry) => entry.value == status)
        .map((entry) => entry.key)
        .toList();
  }

  Future<List<String>> getFriends() =>
      _getUsersWithRelationship(RelationshipStatus.friend);

  Future<List<String>> getBlockedUsers() =>
      _getUsersWithRelationship(RelationshipStatus.blocked);
}

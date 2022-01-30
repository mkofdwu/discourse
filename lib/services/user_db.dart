import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:get/get.dart';

abstract class BaseUserDbService {
  Future<DiscourseUser> getUser(String id);
  Future<DiscourseUser?> getUserByUsername(String username);
  Future<void> setUserData(DiscourseUser user); // updates all user data
  Future<void> deleteUser(String id);
  Future<void> setLastSeen(String id, DateTime? lastSeen);
  Stream<DateTime?> userLastSeenStream(String id);
}

class UserDbService extends GetxService implements BaseUserDbService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  @override
  Future<DiscourseUser> getUser(String id) async {
    return DiscourseUser.fromDoc(await _usersRef.doc(id).get());
  }

  @override
  Future<DiscourseUser?> getUserByUsername(String username) async {
    // used to check if username already exists
    final snapshot =
        await _usersRef.where('username', isEqualTo: username).get();
    if (snapshot.docs.isEmpty) return null;
    return DiscourseUser.fromDoc(snapshot.docs.single);
  }

  @override
  Future<void> setUserData(DiscourseUser user) async {
    // TODO: might need to optimize this
    await _usersRef.doc(user.id).set(user.toData());
  }

  @override
  Future<void> deleteUser(String id) async {
    await _usersRef.doc(id).delete();
  }

  Future<List<DiscourseUser>> searchForUsers(
    String query,
    String currentUserId,
  ) async {
    // temporary solution for firebase, this isn't a very good way of searching.
    if (query.isEmpty) return [];
    final querySnapshot = await _usersRef
        .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
        .limit(10)
        .get();
    final users = <DiscourseUser>[];
    for (final doc in querySnapshot.docs) {
      if (doc.id == currentUserId) continue;
      if (doc
          .data()['username']
          .toLowerCase()
          .startsWith(query.toLowerCase())) {
        users.add(DiscourseUser.fromDoc(doc));
      }
    }
    return users;
  }

  @override
  Future<void> setLastSeen(String id, DateTime? lastSeen) async {
    // id has to be current user's id
    await _usersRef.doc(id).update({'lastSeen': lastSeen});
  }

  @override
  Stream<DateTime?> userLastSeenStream(String id) => _usersRef
      .doc(id)
      .snapshots()
      .asyncMap<DateTime?>((doc) => doc.data()!['lastSeen']?.toDate());
}

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BaseGroupChatDbService {
  Future<List<UserGroupChat>> myGroupChats();
  Future<UserGroupChat> newGroup(GroupChatData data);
  Future<void> updateChatData(String chatId, GroupChatData data);
  Future<void> addMembers(String chatId, List<Member> members);
  Future<void> removeMember(String chatId, String userId);
  Future<void> updateMemberRole(
    String chatId,
    String userId,
    MemberRole newRole,
  );
  Future<void> leaveGroup(String chatId);
}

class GroupChatDbService extends GetxService implements BaseGroupChatDbService {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _groupChatsRef = FirebaseFirestore.instance.collection('groupChats');

  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _requests = Get.find<RequestsService>();
  final _relationships = Get.find<RelationshipsService>();

  String get _userId => _auth.currentUser.id;

  Future<GroupChatData> _getChatData(String chatId) async {
    final doc = await _groupChatsRef.doc(chatId).get();
    final membersSnapshot = await doc.reference.collection('members').get();
    final members = <Member>[];
    for (final mDoc in membersSnapshot.docs) {
      final mData = mDoc.data();
      members.add(Member(
        user: await _userDb.getUser(mData['userId']),
        color: Color(mData['color']),
        role: MemberRole.values[mData['role']],
      ));
    }
    return GroupChatData.fromDoc(doc, members);
  }

  @override
  Future<List<UserGroupChat>> myGroupChats() async {
    final chatsSnapshot =
        await _usersRef.doc(_userId).collection('groupChats').get();
    final userChats = <UserGroupChat>[];
    for (final doc in chatsSnapshot.docs) {
      final data = doc.data();
      userChats.add(UserGroupChat(
        id: doc.id,
        lastReadId: data['lastReadId'],
        pinned: data['pinned'],
        data: await _getChatData(doc.id),
      ));
    }
    return userChats;
  }

  @override
  Future<UserGroupChat> newGroup(GroupChatData data) async {
    final chatDoc = await _groupChatsRef.add(data.toData());
    addMembers(chatDoc.id, data.members);
    return UserGroupChat(
      id: chatDoc.id,
      lastReadId: null,
      pinned: false,
      data: data,
    );
  }

  @override
  Future<void> updateChatData(String chatId, GroupChatData newData) async {
    await _groupChatsRef.doc(chatId).update(newData.toData());
  }

  @override
  Future<void> addMembers(
    String chatId,
    List<Member> members,
  ) async {
    for (final member in members) {
      // as of now there is no security on the backend to enforce permissions
      final rs = await _relationships.relationshipWithMe(member.user.id);
      if (_relationships.isRequestNeeded(rs, RequestType.groupInvite)) {
        await _requests.sendRequest(Request(
          fromUserId: _userId,
          toUserId: member.user.id,
          type: RequestType.groupInvite,
          data: chatId,
        ));
      } else {
        await _usersRef
            .doc(member.user.id)
            .collection('chats')
            .doc(chatId)
            .set({'type': 1, 'lastReadId': null});
        await _groupChatsRef
            .doc(chatId)
            .collection('members')
            .doc(member.user.id)
            .set(member.toData());
      }
    }
  }

  @override
  Future<void> removeMember(String chatId, String userId) async {
    await _groupChatsRef.doc(chatId).collection('members').doc(userId).delete();
  }

  @override
  Future<void> updateMemberRole(
    String chatId,
    String userId,
    MemberRole newRole,
  ) async {
    await _groupChatsRef
        .doc(chatId)
        .collection('members')
        .doc(userId)
        .update({'role': newRole.index});
  }

  @override
  Future<void> leaveGroup(String chatId) async {
    await removeMember(chatId, _auth.currentUser.id);
    await _usersRef
        .doc(_auth.currentUser.id)
        .collection('chats')
        .doc(chatId)
        .delete();
  }
}

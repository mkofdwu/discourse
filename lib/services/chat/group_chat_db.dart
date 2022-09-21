import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_alert.dart';
import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/message_link.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BaseGroupChatDbService {
  Future<GroupChatData> getChatData(String chatId);
  Future<UserGroupChat> newGroup(
    GroupChatData data,
    List<DiscourseUser> sendInvitesTo,
    List<DiscourseUser> addMembers,
  );
  Future<void> addOrSendInvites(String chatId, List<Member> members);
  Future<void> removeMember(String chatId, DiscourseUser user);
  Future<void> makeAdmin(String chatId, DiscourseUser user);
  Future<void> revokeAdmin(String chatId, DiscourseUser user);
  Future<void> transferOwnership(String chatId, DiscourseUser user);
  Future<void> leaveGroup(String chatId);
}

// this class is also responsible for adding chat alerts to the log
class GroupChatDbService extends GetxService implements BaseGroupChatDbService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _requests = Get.find<RequestsService>();
  final _relationships = Get.find<RelationshipsService>();
  final _chatLogDb = Get.find<ChatLogDbService>();

  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _messagesRef = FirebaseFirestore.instance.collection('messages');
  final _groupChatsRef = FirebaseFirestore.instance.collection('groupChats');

  @override
  Future<GroupChatData> getChatData(String chatId) async {
    final doc = await _groupChatsRef.doc(chatId).get();
    final membersSnapshot = await doc.reference.collection('members').get();
    final members = <Member>[];
    for (final mDoc in membersSnapshot.docs) {
      final mData = mDoc.data();
      members.add(Member(
        user: await _userDb.getUser(mDoc.id),
        color: Color(mData['color']),
        role: MemberRole.values[mData['role']],
      ));
    }
    final linksSnapshot = await doc.reference.collection('links').get();
    final links = <MessageLink>[];
    for (final linkDoc in linksSnapshot.docs) {
      links.add(MessageLink.fromDoc(linkDoc));
    }
    return GroupChatData.fromDoc(doc, members, links);
  }

  Future<void> updateName(
    String chatId,
    String newName, {
    required String oldName,
  }) async {
    await _groupChatsRef.doc(chatId).update({'name': newName});
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.editName,
      '${_auth.currentUser.username} changed the group name from "$oldName" to "$newName"',
    );
  }

  Future<void> updateDescription(String chatId, String newDescription) async {
    await _groupChatsRef.doc(chatId).update({'description': newDescription});
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.editDescription,
      '${_auth.currentUser.username} changed the group description',
    );
  }

  Future<void> updatePhoto(String chatId, String? newPhotoUrl) async {
    await _groupChatsRef.doc(chatId).update({'photoUrl': newPhotoUrl});
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.editPhoto,
      '${_auth.currentUser.username} changed the group photo',
    );
  }

  @override
  Future<UserGroupChat> newGroup(
    GroupChatData data,
    List<DiscourseUser> sendInvitesTo,
    List<DiscourseUser> addMembers,
  ) async {
    final chatDoc = await _groupChatsRef.add(data.toData());
    await _messagesRef.doc(chatDoc.id).set({});

    final owner = Member.create(_auth.currentUser, role: MemberRole.owner);
    await _addMember(chatDoc.id, owner, sendAlert: false);
    data.members.add(owner);

    await _chatLogDb.newAlert(
      chatDoc.id,
      ChatAction.memberJoin,
      '${_auth.currentUser.username} created this group',
    );

    for (DiscourseUser user in addMembers) {
      final member = Member.create(user);
      _addMember(chatDoc.id, member);
      data.members.add(member);
    }
    for (DiscourseUser user in sendInvitesTo) {
      _sendGroupInvite(chatDoc.id, user.id);
    }

    return UserGroupChat(
      id: chatDoc.id,
      lastReadAt: null,
      pinned: false,
      data: data,
    );
  }

  Future<void> _addMember(String chatId, Member member,
      {bool sendAlert = true}) async {
    // as of now there is no security on the backend to enforce permissions
    // assert(!(await _relationships.needToAsk(
    //     member.user.id, RequestType.groupInvite)));
    await _usersRef
        .doc(member.user.id)
        .collection('chats')
        .doc(chatId)
        .set({'type': 1, 'lastReadAt': null, 'pinned': false});
    await _groupChatsRef
        .doc(chatId)
        .collection('members')
        .doc(member.user.id)
        .set(member.toData());
    if (sendAlert) {
      await _chatLogDb.newAlert(
        chatId,
        ChatAction.addMember,
        '${_auth.currentUser.username} added ${member.user.username} to this group',
      );
    }
  }

  Future<void> _sendGroupInvite(String chatId, String userId) async {
    // assert(await _relationships.needToAsk(user.id, RequestType.groupInvite));
    await _requests.sendRequest(UnsentRequest(
      toUserId: userId,
      type: RequestType.groupInvite,
      data: chatId,
    ));
  }

  @override
  Future<void> addOrSendInvites(String chatId, List<Member> members) async {
    for (final member in members) {
      // as of now there is no security on the backend to enforce permissions
      if (await _relationships.needToAsk(
          member.user.id, RequestType.groupInvite)) {
        await _sendGroupInvite(chatId, member.user.id);
      } else {
        await _addMember(chatId, member);
      }
    }
  }

  Future<void> addUserGroupChat(String chatId) async {
    await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .doc(chatId)
        .set({'type': 1, 'lastReadAt': null, 'pinned': false});
    await _groupChatsRef
        .doc(chatId)
        .collection('members')
        .doc(_auth.id)
        .set(Member.create(_auth.currentUser).toData());
  }

  Future<void> _removeMember(String chatId, String userId) async {
    await _groupChatsRef.doc(chatId).collection('members').doc(userId).delete();
  }

  @override
  Future<void> removeMember(String chatId, DiscourseUser user) async {
    await _removeMember(chatId, user.id);
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.removeMember,
      '${_auth.currentUser.username} removed ${user.username} from this group',
    );
  }

  Future<void> _updateMemberRole(
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
  Future<void> makeAdmin(String chatId, DiscourseUser user) async {
    await _updateMemberRole(chatId, user.id, MemberRole.admin);
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.addAdmin,
      '${_auth.currentUser.username} granted ${user.username} admin permissions',
    );
  }

  @override
  Future<void> revokeAdmin(String chatId, DiscourseUser user) async {
    await _updateMemberRole(chatId, user.id, MemberRole.member);
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.removeAdmin,
      '${_auth.currentUser.username} revoked ${user.username}\'s admin permissions',
    );
  }

  @override
  Future<void> transferOwnership(String chatId, DiscourseUser user) async {
    await _updateMemberRole(chatId, _auth.id, MemberRole.admin);
    await _updateMemberRole(chatId, user.id, MemberRole.owner);
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.transferOwnership,
      '${_auth.currentUser.username} transferred ownership of this group to ${user.username}',
    );
  }

  @override
  Future<void> leaveGroup(String chatId) async {
    await _removeMember(chatId, _auth.id);
    await _usersRef.doc(_auth.id).collection('chats').doc(chatId).delete();
    await _chatLogDb.newAlert(
      chatId,
      ChatAction.memberLeave,
      '${_auth.currentUser.username} left this group',
    );
  }
}

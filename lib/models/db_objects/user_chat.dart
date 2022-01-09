import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

abstract class UserChat {
  final String id;
  String? lastReadId;
  bool pinned;
  ChatData data;

  UserChat({
    required this.id,
    this.lastReadId,
    required this.pinned,
    required this.data,
  });

  String get title;
  String? get subtitle;

  PrivateChatData get privateData => data as PrivateChatData;
  GroupChatData get groupData => data as GroupChatData;

  @override
  bool operator ==(Object other) => other is UserChat && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class UserPrivateChat extends UserChat {
  UserPrivateChat({
    required String id,
    String? lastReadId,
    required bool pinned,
    required PrivateChatData data,
  }) : super(
          id: id,
          lastReadId: lastReadId,
          pinned: pinned,
          data: data,
        );

  @override
  String get title => (data as PrivateChatData).otherUser.username;

  @override
  String? get subtitle => null;
}

class UserGroupChat extends UserChat {
  UserGroupChat({
    required String id,
    String? lastReadId,
    required bool pinned,
    required GroupChatData data,
  }) : super(
          id: id,
          lastReadId: lastReadId,
          pinned: pinned,
          data: data,
        );

  @override
  String get title => (data as GroupChatData).name;
  @override
  String get subtitle => '${(data as GroupChatData).members.length} members';
}

class NonExistentChat extends UserChat {
  // private chat that does not have any messages yet

  NonExistentChat({
    required DiscourseUser otherUser,
    required List<Member> members,
  }) : super(
          id: '',
          pinned: false,
          data: NonExistentChatData(otherUser: otherUser),
        );

  @override
  String get title => (data as NonExistentChatData).otherUser.username;

  @override
  String? get subtitle => null;
}

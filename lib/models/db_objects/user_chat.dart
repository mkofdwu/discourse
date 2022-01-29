import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';

abstract class UserChat {
  final String id;
  DateTime? lastReadAt;
  bool pinned;
  ChatData data;

  UserChat({
    required this.id,
    this.lastReadAt,
    required this.pinned,
    required this.data,
  });

  String? get photoUrl;
  String get title;
  String? get subtitle;

  PrivateChatData get privateData => data as PrivateChatData;
  GroupChatData get groupData => data as GroupChatData;
  NonExistentChatData get nonExistentData => data as NonExistentChatData;

  @override
  bool operator ==(Object other) => other is UserChat && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class UserPrivateChat extends UserChat {
  final DiscourseUser otherUser;

  UserPrivateChat({
    required String id,
    DateTime? lastReadAt,
    required bool pinned,
    required this.otherUser,
    required PrivateChatData data,
  }) : super(
          id: id,
          lastReadAt: lastReadAt,
          pinned: pinned,
          data: data,
        );

  @override
  String? get photoUrl => otherUser.photoUrl;

  @override
  String get title => otherUser.username;

  @override
  String? get subtitle => null;
}

class UserGroupChat extends UserChat {
  UserGroupChat({
    required String id,
    DateTime? lastReadAt,
    required bool pinned,
    required GroupChatData data,
  }) : super(
          id: id,
          lastReadAt: lastReadAt,
          pinned: pinned,
          data: data,
        );

  @override
  String? get photoUrl => groupData.photoUrl;

  @override
  String get title => groupData.name;

  @override
  String get subtitle => '${groupData.members.length} members';
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
  String? get photoUrl => null;

  @override
  String get title => nonExistentData.otherUser.username;

  @override
  String? get subtitle => null;
}

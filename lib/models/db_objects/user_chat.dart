import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';

abstract class UserChat {
  final String id;
  String? lastReadId;
  bool pinned;

  UserChat({
    required this.id,
    this.lastReadId,
    required this.pinned,
  });

  String? get photoUrl;
  String get title;
  String? get subtitle;

  // PrivateChatData get privateData => data as PrivateChatData;
  // GroupChatData get groupData => data as GroupChatData;

  @override
  bool operator ==(Object other) => other is UserChat && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class UserPrivateChat extends UserChat {
  final DiscourseUser otherUser;
  PrivateChatData data;

  UserPrivateChat({
    required String id,
    String? lastReadId,
    required bool pinned,
    required this.otherUser,
    required this.data,
  }) : super(
          id: id,
          lastReadId: lastReadId,
          pinned: pinned,
        );

  @override
  String? get photoUrl => otherUser.photoUrl;

  @override
  String get title => otherUser.username;

  @override
  String? get subtitle => null;
}

class UserGroupChat extends UserChat {
  GroupChatData data;

  UserGroupChat({
    required String id,
    String? lastReadId,
    required bool pinned,
    required this.data,
  }) : super(
          id: id,
          lastReadId: lastReadId,
          pinned: pinned,
        );

  @override
  String? get photoUrl => data.photoUrl;

  @override
  String get title => data.name;

  @override
  String get subtitle => '${data.members.length} members';
}

class NonExistentChat extends UserChat {
  // private chat that does not have any messages yet
  NonExistentChatData data;

  NonExistentChat({
    required DiscourseUser otherUser,
    required List<Member> members,
  })  : data = NonExistentChatData(otherUser: otherUser),
        super(id: '', pinned: false);

  @override
  String? get photoUrl => null;

  @override
  String get title => data.otherUser.username;

  @override
  String? get subtitle => null;
}

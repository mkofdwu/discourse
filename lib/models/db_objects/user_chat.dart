import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/utils/format_date_time.dart';
import 'package:get/get.dart';

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
  Stream<String?> get subtitle;

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
  Stream<String?> get subtitle => Get.find<UserDbService>()
          .userLastSeenStream(otherUser.id)
          .asyncMap((lastSeen) {
        if (lastSeen == null) return 'online';
        return 'last seen ' +
            (isSameDay(lastSeen, DateTime.now())
                ? formatTime(lastSeen)
                : formatDate(lastSeen));
      });
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
  Stream<String> get subtitle =>
      Stream.value('${groupData.members.length} members');
}

class NonExistentChat extends UserChat {
  // private chat that does not have any messages yet
  final DiscourseUser otherUser;

  NonExistentChat({
    required this.otherUser,
    required List<Member> members,
  }) : super(
          id: '',
          pinned: false,
          data: NonExistentChatData(),
        );

  @override
  String? get photoUrl => otherUser.photoUrl;

  @override
  String get title => otherUser.username;

  @override
  Stream<String?> get subtitle => Get.find<UserDbService>()
          .userLastSeenStream(otherUser.id)
          .asyncMap((lastSeen) {
        if (lastSeen == null) return 'online';
        return 'last seen ' +
            (isSameDay(lastSeen, DateTime.now())
                ? formatTime(lastSeen)
                : formatDate(lastSeen));
      });
}

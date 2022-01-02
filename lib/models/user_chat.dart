import 'package:discourse/models/chat_data.dart';
import 'package:discourse/models/chat_participant.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

abstract class UserChat {
  final String id;
  String? lastReadId;
  // bool starred;
  ChatData data;

  UserChat({required this.id, this.lastReadId, required this.data});

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
    required PrivateChatData data,
  }) : super(
          id: id,
          lastReadId: lastReadId,
          data: data,
        );

  Participant get otherParticipant {
    final userId = Get.find<AuthService>().currentUser.id;
    return data.participants.firstWhere((p) => p.user.id != userId);
  }

  @override
  String get title => otherParticipant.user.username;

  @override
  String? get subtitle => null;
}

class UserGroupChat extends UserChat {
  UserGroupChat({
    required String id,
    String? lastReadId,
    required GroupChatData data,
  }) : super(
          id: id,
          lastReadId: lastReadId,
          data: data,
        );

  @override
  String get title => (data as GroupChatData).name;
  @override
  String get subtitle =>
      '${(data as GroupChatData).participants.length} participants';
}

class NonExistentChat extends UserChat {
  // private chat that does not have any messages yet
  final DiscourseUser otherUser;

  NonExistentChat({
    required this.otherUser,
    required List<Participant> participants,
  }) : super(
          id: '',
          data: NonExistentChatData(participants: participants),
        );

  @override
  String get title => otherUser.username;

  @override
  String? get subtitle => null;
}

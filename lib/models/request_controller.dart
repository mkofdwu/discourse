import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/models/db_objects/received_request.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/requests.dart';
import 'package:get/get.dart';

// FUTURE: setup express server to handle this instead of locally
abstract class RequestController {
  final _requests = Get.find<RequestsService>();

  final ReceivedRequest request;

  RequestController(this.request);

  Future<void> loadData(); // used by groupinvite request to fetch group data

  String get title;
  String get subtitle;
  String? get photoUrl;

  // called when the request is accepted
  Future<void> performAction();

  factory RequestController.create(ReceivedRequest request) {
    switch (request.type) {
      case RequestType.talk:
        return TalkRequestController(request);
      case RequestType.friend:
        return FriendRequestController(request);
      case RequestType.groupInvite:
        return GroupInviteRequestController(request);
    }
  }

  Future<void> acceptRequest() async {
    await _requests.acceptRequest(request);
    await performAction();
  }

  Future<void> rejectRequest() async {
    await _requests.rejectRequest(request);
  }
}

class TalkRequestController extends RequestController {
  final _relationships = Get.find<RelationshipsService>();
  final _privateChatDb = Get.find<PrivateChatDbService>();

  TalkRequestController(ReceivedRequest request) : super(request);

  @override
  Future<void> loadData() async {}

  @override
  String get title => request.fromUser.username;

  @override
  String get subtitle => 'Wants to send a message';

  @override
  String? get photoUrl => request.fromUser.photoUrl;

  @override
  Future<void> performAction() async {
    // TODO: if this is a degrade do nothing
    await _relationships.setMutualRelationship(
        request.fromUser.id, RelationshipStatus.canTalk);
    await _privateChatDb.addUserPrivateChat(request.data, request.fromUser.id);
  }
}

class FriendRequestController extends RequestController {
  final _relationships = Get.find<RelationshipsService>();

  FriendRequestController(ReceivedRequest request) : super(request);

  @override
  Future<void> loadData() async {}

  @override
  String get title => request.fromUser.username;

  @override
  String get subtitle => 'Friend request';

  @override
  String? get photoUrl => request.fromUser.photoUrl;

  @override
  Future<void> performAction() async {
    // TODO: if this is a degrade do nothing
    await _relationships.setMutualRelationship(
        request.fromUser.id, RelationshipStatus.friend);
  }
}

class GroupInviteRequestController extends RequestController {
  final _relationships = Get.find<RelationshipsService>();
  final _groupChatDb = Get.find<GroupChatDbService>();

  GroupChatData? _chatData;

  GroupInviteRequestController(ReceivedRequest request) : super(request);

  @override
  Future<void> loadData() async {
    _chatData = await _groupChatDb.getChatData(request.data);
  }

  @override
  String get title => _chatData!.name;

  @override
  String get subtitle => '${_chatData!.members.length} members';

  @override
  String? get photoUrl => _chatData!.photoUrl;

  @override
  Future<void> performAction() async {
    // TODO: if this is a degrade do nothing
    await _relationships.setMutualRelationship(
        request.fromUser.id, RelationshipStatus.canTalk);
    await _groupChatDb.addUserGroupChat(request.data);
  }
}

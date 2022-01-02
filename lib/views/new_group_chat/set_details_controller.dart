import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat_db.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:discourse/models/chat_data.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/models/chat_participant.dart';

class SetDetailsController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _storageService = Get.find<StorageService>();
  final _mediaService = Get.find<MediaService>();
  final _chatDb = Get.find<ChatDbService>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<DiscourseUser> _participants;
  Photo? _photo;

  bool get hasPhoto => _photo != null;
  Photo? get photo => _photo;

  SetDetailsController(this._participants);

  Future<void> selectPhoto() async {
    _photo = await _mediaService.selectPhoto();
    update();
  }

  Future<void> createGroup() async {
    final participants = <Participant>[];
    final admin = Participant.create(
      _auth.currentUser,
      role: ParticipantRole.admin,
    );
    participants.add(admin);
    participants.addAll(_participants.map(
      (user) => Participant.create(user),
    ));

    if (_photo != null && _photo!.isLocal) {
      await _storageService.uploadPhoto(_photo!, 'group_photo');
    }

    final groupData = GroupChatData(
      name: nameController.text,
      description: descriptionController.text,
      photoUrl: _photo!.url,
      participants: participants,
      lastMessageText: null,
    );
    final userChat = await _chatDb.newGroup(groupData);

    Get.offAll(ChatView(userChat: userChat));
  }
}

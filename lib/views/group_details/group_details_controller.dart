import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';

class GroupDetailsController extends GetxController {
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _media = Get.find<MediaService>();
  final _storage = Get.find<StorageService>();

  final UserGroupChat _chat;

  GroupDetailsController(this._chat);

  void viewGroupPhoto() async {
    if (_chat.photoUrl != null) {
      await Get.to(ExaminePhotoView(
        title: 'Group photo',
        photo: Photo.url(_chat.photoUrl),
        suffixIcons: {
          FluentIcons.more_vertical_24_regular: () async {
            final choice = await Get.bottomSheet(ChoiceBottomSheet(
              title: 'Options',
              choices: const ['Change photo', 'Remove photo'],
            ));
            if (choice == null) return;
            switch (choice) {
              case 'Change photo':
                selectPhoto();
                break;
              case 'Remove photo':
                _askRemovePhoto();
                break;
            }
          },
        },
      ));
    } else {
      selectPhoto();
    }
  }

  void selectPhoto() async {
    final newPhoto = await _media.selectPhoto();
    if (newPhoto != null) {
      await _storage.uploadPhoto(newPhoto, 'groupphoto');
      _chat.data.photoUrl = newPhoto.url;
      await _groupChatDb.updateChatData(_chat.id, _chat.data);
      update();
    }
  }

  void _askRemovePhoto() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Remove photo?',
      subtitle: 'Are you sure you want to remove the group photo?',
    ));
    if (confirmed ?? false) {
      _chat.data.photoUrl = null;
      await _groupChatDb.updateChatData(_chat.id, _chat.data);
      Get.back();
      update();
    }
  }

  void editNameAndDescription() {
    Get.to(CustomFormView(
      form: CustomForm(
        title: 'Group details',
        fields: [
          Field(
            'name',
            _chat.data.name,
            textFieldBuilder(label: 'Name'),
          ),
          Field(
            'description',
            _chat.data.description,
            textFieldBuilder(
              label: 'Description',
              isMultiline: true,
              isLast: true,
            ),
          ),
        ],
        onSubmit: (inputs, setErrors) async {
          if (inputs['name'].isEmpty) {
            setErrors({'name': 'Your group needs to have a name'});
            return;
          }
          _chat.data.name = inputs['name'];
          _chat.data.description = inputs['description'];
          await _groupChatDb.updateChatData(_chat.id, _chat.data);
          update();
        },
      ),
    ));
  }

  void showMemberOptions(Member member) {}

  void goToAddMembers() {
    Get.to(UserSelectorView(
      title: 'Add members',
      canSelectMultiple: true,
      onSubmit: (selectedUsers) async {
        await _groupChatDb.addOrSendInvites(
          _chat.id,
          selectedUsers.map((user) => Member.create(user)).toList(),
        );
        Get.back();
        Get.snackbar(
          'Added members',
          'Successfully added or sent invites to ${selectedUsers.length} users',
        );
      },
    ));
  }

  void leaveGroup() {}

  void deleteGroup() {}
}

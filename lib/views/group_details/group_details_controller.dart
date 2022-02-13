import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:discourse/views/media_list/media_list_view.dart';
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

  DiscourseUser get currentUser => Get.find<AuthService>().currentUser;

  MemberRole get currentUserRole => _chat.groupData.members
      .singleWhere((member) => member.user == currentUser)
      .role;

  bool get hasAdminPrivileges =>
      currentUserRole == MemberRole.admin ||
      currentUserRole == MemberRole.owner;

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
      await _groupChatDb.updatePhoto(_chat.id, newPhoto.url);
      _chat.groupData.photoUrl = newPhoto.url;
      update();
    }
  }

  void _askRemovePhoto() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Remove photo?',
      subtitle: 'Are you sure you want to remove the group photo?',
    ));
    if (confirmed ?? false) {
      await _groupChatDb.updatePhoto(_chat.id, null);
      _chat.groupData.photoUrl = null;
      Get.back();
      update();
    }
  }

  void editNameAndDescription() {
    if (!hasAdminPrivileges) return;
    Get.to(CustomFormView(
      form: CustomForm(
        title: 'Group details',
        fields: [
          Field(
            'name',
            _chat.groupData.name,
            textFieldBuilder(label: 'Name'),
          ),
          Field(
            'description',
            _chat.groupData.description,
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
          if (inputs['name'] != _chat.groupData.name) {
            await _groupChatDb.updateName(
              _chat.id,
              inputs['name'],
              oldName: _chat.groupData.name,
            );
            _chat.groupData.name = inputs['name'];
          }
          if (inputs['description'] != _chat.groupData.description) {
            await _groupChatDb.updateDescription(
              _chat.id,
              inputs['description'],
            );
            _chat.groupData.description = inputs['description'];
          }
          Get.back();
          update();
        },
      ),
    ));
  }

  void showMemberOptions(Member member) async {
    if (!hasAdminPrivileges) return;
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Member options',
      choices: [
        if (member.role == MemberRole.member) 'Make admin',
        if (member.role == MemberRole.admin) 'Remove admin',
        if (currentUserRole == MemberRole.owner) 'Transfer ownership',
        'Remove member',
      ],
    ));
    if (choice == null) return;
    switch (choice) {
      case 'Make admin':
        final confirmed = await Get.bottomSheet(YesNoBottomSheet(
          title: 'Make admin?',
          subtitle: 'Grant admin permissions to ${member.user.username}?',
        ));
        if (confirmed ?? false) {
          await _groupChatDb.makeAdmin(_chat.id, member.user);
          member.role = MemberRole.admin;
          update();
        }
        break;
      case 'Remove admin':
        final confirmed = await Get.bottomSheet(YesNoBottomSheet(
          title: 'Remove admin?',
          subtitle: "Revoke ${member.user.username}'s admin premissions?",
        ));
        if (confirmed ?? false) {
          await _groupChatDb.revokeAdmin(_chat.id, member.user);
          member.role = MemberRole.member;
          update();
        }
        break;
      case 'Transfer ownersip':
        final confirmed = await Get.bottomSheet(YesNoBottomSheet(
          title: 'Transfer ownership?',
          subtitle:
              "Make ${member.user.username} the owner of this group? You'll lose your ownership status",
        ));
        if (confirmed ?? false) {
          await _groupChatDb.transferOwnership(_chat.id, member.user);
          member.role = MemberRole.member;
          final currentUserMember = _chat.groupData.members
              .singleWhere((member) => member.user == currentUser);
          currentUserMember.role = MemberRole.admin;
          update();
        }
        break;
      case 'Remove member':
        final confirmed = await Get.bottomSheet(YesNoBottomSheet(
          title: 'Remove member?',
          subtitle: "Remove ${member.user.username} from this group?",
        ));
        if (confirmed ?? false) {
          await _groupChatDb.removeMember(_chat.id, member.user);
          _chat.groupData.members.remove(member);
          update();
        }
        break;
    }
  }

  void toAddMembers() {
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

  void toExaminePhoto(String photoUrl) {
    Get.to(ExaminePhotoView(photo: Photo.url(photoUrl)));
  }

  void toPhotosAndVideos() {
    Get.to(MediaListView(photoUrls: _chat.data.mediaUrls.reversed.toList()));
  }

  void leaveGroup() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Leave group?',
      subtitle:
          'Are you sure you want to leave this chat? You will need someone to add you back in afterwards.',
    ));
    if (confirmed ?? false) {
      // TODO: fixme startreading / stop reading chat is triggered after this
      // causing an error and update() is not called in home page
      await _groupChatDb.leaveGroup(_chat.id);
      Get.back();
      Get.back();
    }
  }

  void deleteGroup() {}
}

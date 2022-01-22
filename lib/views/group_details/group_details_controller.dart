import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:get/get.dart';

class GroupDetailsController extends GetxController {
  final _groupChatDb = Get.find<GroupChatDbService>();

  final UserGroupChat _chat;

  GroupDetailsController(this._chat);

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
            textFieldBuilder(label: 'Description', isMultiline: true),
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
      canSelectMultiple: true,
      onSubmit: (selectedUsers) async {
        await _groupChatDb.addMembers(
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

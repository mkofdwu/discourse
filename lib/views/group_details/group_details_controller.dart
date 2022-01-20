import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
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
            textFieldBuilder(
              label: 'Name',
              defaultValue: _chat.data.name,
            ),
          ),
          Field(
            'description',
            textFieldBuilder(
              label: 'Description',
              defaultValue: _chat.data.description,
              isMultiline: true,
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
        },
      ),
    ));
  }

  void goToAddMembers() {}

  void leaveGroup() {}

  void deleteGroup() {}
}

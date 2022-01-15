import 'package:discourse/views/set_group_details/set_group_details_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

class GroupsController extends GetxController {
  void newGroup() {
    Get.to(UserSelectorView(
      canSelectMultiple: true,
      onSubmit: (selectedUsers) async {
        Get.off(SetGroupDetailsView(members: selectedUsers));
      },
    ));
  }

  void showGroupOptions() {
    Get.bottomSheet(
      ChoiceBottomSheet(
        title: 'Group options',
        choices: const [
          'Find in chat',
          'Export history',
          'Clear chat',
          'Leave group'
        ],
      ),
    );
  }
}

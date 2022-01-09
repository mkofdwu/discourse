import 'package:discourse/widgets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

class GroupsController extends GetxController {
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

import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/group_details/group_details_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

Future<void> showGroupChatOptions(UserGroupChat chat) async {
  final choice = await Get.bottomSheet(ChoiceBottomSheet(
    title: 'Chat options',
    choices: const [
      'View details',
      'Find in chat',
      'Export history',
      'Clear chat',
      'Leave group',
    ],
  ));
  if (choice == null) return;
  switch (choice) {
    case 'View details':
      Get.to(GroupDetailsView(chat: chat));
      break;
    // TODO
    case 'Find in chat':
      break;
    case 'Export history':
      break;
    case 'Clear chat':
      break;
    case 'Leave group':
      break;
  }
}

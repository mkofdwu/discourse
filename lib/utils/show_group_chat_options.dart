import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

Future<void> showGroupChatOptions() async {
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
}

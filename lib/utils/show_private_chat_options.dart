import 'package:discourse/widgets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

Future<void> showPrivateChatOptions() async {
  final choice = await Get.bottomSheet(ChoiceBottomSheet(
    title: 'Chat options',
    choices: const [
      'View profile',
      'Find in chat',
      'Export history',
      'Clear chat',
      'Remove friend',
    ],
  ));
  switch (choice) {
    case 'View profile':
      break;
    case 'Find in chat':
      break;
    case 'Export history':
      break;
    case 'Clear chat':
      break;
    case 'Remove friend':
      break;
  }
}

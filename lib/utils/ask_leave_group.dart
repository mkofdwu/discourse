import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

void askLeaveGroup(String chatId) async {
  final confirmed = await Get.bottomSheet(YesNoBottomSheet(
    title: 'Leave chat?',
    subtitle:
        'Are you sure you want to leave this chat? You will need someone to add you back in afterwards.',
  ));
  if (confirmed ?? false) {
    await Get.find<GroupChatDbService>().leaveGroup(chatId);
  }
}

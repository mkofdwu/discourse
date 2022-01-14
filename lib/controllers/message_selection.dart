import 'package:discourse/models/db_objects/message.dart';
import 'package:get/get.dart';

class MessageSelectionController extends GetxController {
  final selectedMessages = <Message>[].obs;

  bool get isSelecting => selectedMessages.isNotEmpty;

  void toggleSelectMessage(Message message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }
  }

  void cancelSelection() {
    selectedMessages.clear();
  }
}

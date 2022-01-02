import 'package:discourse/models/message.dart';

class MessageSelectionService {
  final selectedMessages = <Message>[];

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

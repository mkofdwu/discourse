import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';

class UnsentMessage {
  String chatId;
  RepliedMessage? repliedMessage;
  Photo? photo;
  String? text;

  UnsentMessage({
    required this.chatId,
    this.repliedMessage,
    this.photo,
    this.text,
  });

  @override
  String toString() =>
      'UnsentMessage(chatId: $chatId, repliedMessage: $repliedMessage, photo: $photo, text: $text)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UnsentMessage &&
        other.chatId == chatId &&
        other.repliedMessage == repliedMessage &&
        other.photo == photo &&
        other.text == text;
  }

  @override
  int get hashCode =>
      chatId.hashCode ^
      repliedMessage.hashCode ^
      photo.hashCode ^
      text.hashCode;
}

import 'package:discourse/models/db_objects/chat_alert.dart';
import 'package:discourse/models/db_objects/message.dart';

abstract class ChatLogObject {
  bool get isMessage;

  Message get asMessage => this as Message;
  ChatAlert get asChatAlert => this as ChatAlert;

  String get id => isMessage ? asMessage.id : asChatAlert.id;
  DateTime get sentTimestamp =>
      isMessage ? asMessage.sentTimestamp : asChatAlert.sentTimestamp;
}

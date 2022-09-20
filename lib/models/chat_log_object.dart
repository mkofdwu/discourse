import 'package:discourse/models/db_objects/chat_alert.dart';
import 'package:discourse/models/db_objects/message.dart';

abstract class ChatLogObject {
  abstract final String id;
  abstract DateTime sentTimestamp;

  Message get asMessage => this as Message;
  ChatAlert get asChatAlert => this as ChatAlert;
}

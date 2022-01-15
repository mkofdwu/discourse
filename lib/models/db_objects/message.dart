import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

class Message {
  final String id;
  String chatId;
  DiscourseUser sender;
  RepliedMessage? repliedMessage;
  Photo? photo;
  String? text;
  DateTime sentTimestamp;

  // attributes not stored in db
  bool fromMe;

  bool get isDeleted => text == null && photo == null;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    this.repliedMessage,
    this.photo,
    this.text,
    required this.sentTimestamp,
    required this.fromMe,
  });

  factory Message.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    DiscourseUser sender,
    RepliedMessage repliedMessage,
  ) {
    final data = doc.data()!;
    final chatId = doc.reference.parent.parent!.id;
    return Message(
      id: doc.id,
      chatId: chatId,
      sender: sender,
      repliedMessage: repliedMessage,
      photo: Photo.url(data['photo']),
      text: data['text'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      fromMe: sender.id == Get.find<AuthService>().currentUser.id,
    );
  }

  Map<String, dynamic> toData() => {
        'senderId': sender.id,
        'repliedMessageId': repliedMessage?.id,
        'photoUrl': photo?.url,
        'text': text,
        'sentTimestamp': Timestamp.fromDate(sentTimestamp),
      };

  RepliedMessage asRepliedMessage() => RepliedMessage(
        id: id,
        sender: sender,
        photo: photo,
        text: text,
      );

  @override
  bool operator ==(Object other) => other is Message && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Message(id: $id, text: $text, fromMe: $fromMe)';
}

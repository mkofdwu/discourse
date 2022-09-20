import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

class GroupInvite extends ChatLogObject {
  @override
  final String id;
  DiscourseUser sender;
  String chatId;
  @override
  DateTime sentTimestamp;

  bool get fromMe => sender.id == Get.find<AuthService>().currentUser.id;

  GroupInvite({
    required this.id,
    required this.sender,
    required this.chatId,
    required this.sentTimestamp,
  });

  factory GroupInvite.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    DiscourseUser sender,
  ) {
    final data = doc.data()!;
    return GroupInvite(
      id: doc.id,
      sender: sender,
      chatId: doc.reference.parent.parent!.id,
      sentTimestamp: data['sentTimestamp'].toDate(),
    );
  }

  Map<String, dynamic> toData() {
    return {
      'senderId': sender.id,
      'chatId': chatId,
      'sentTimestamp': sentTimestamp,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';

enum ChatType { private, group }

abstract class ChatData {}

class PrivateChatData extends ChatData {
  PrivateChatData();
}

class GroupChatData extends ChatData {
  String name;
  String description;
  String? photoUrl;
  final List<Member> members;

  GroupChatData({
    required this.name,
    required this.description,
    this.photoUrl,
    required this.members,
  });

  factory GroupChatData.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<Member> members,
  ) {
    final data = doc.data()!;
    return GroupChatData(
      name: data['name'],
      description: data['description'],
      photoUrl: data['photoUrl'],
      members: members,
    );
  }

  Map<String, dynamic> toData() {
    return {
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
    };
  }
}

class NonExistentChatData extends ChatData {
  final DiscourseUser otherUser;

  NonExistentChatData({required this.otherUser});
}
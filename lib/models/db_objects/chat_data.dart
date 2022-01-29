import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';

enum ChatType { private, group }

abstract class ChatData {
  List<String> mediaUrls; // photos and videos (just photos for now)

  ChatData(this.mediaUrls);
}

class PrivateChatData extends ChatData {
  PrivateChatData({required List<String> mediaUrls}) : super(mediaUrls);

  factory PrivateChatData.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PrivateChatData(mediaUrls: List<String>.from(data['mediaUrls']));
  }

  Map<String, dynamic> toData() {
    return {'mediaUrls': mediaUrls};
  }
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
    required List<String> mediaUrls,
  }) : super(mediaUrls);

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
      mediaUrls: List<String>.from(data['mediaUrls']),
    );
  }

  Map<String, dynamic> toData() {
    return {
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'mediaUrls': mediaUrls,
    };
  }
}

class NonExistentChatData extends ChatData {
  final DiscourseUser otherUser;

  NonExistentChatData({required this.otherUser}) : super([]);
}

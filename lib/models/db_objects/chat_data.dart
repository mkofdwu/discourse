import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/message_link.dart';
import 'package:discourse/models/db_objects/message_media_url.dart';
import 'package:get/get.dart';

enum ChatType { private, group }

abstract class ChatData {
  RxList<MessageMedia> media; // photos and videos (just photos for now)
  RxList<MessageLink> links;

  ChatData(this.media, this.links);
}

class PrivateChatData extends ChatData {
  PrivateChatData({
    required List<MessageMedia> mediaUrls,
    required List<MessageLink> links,
  }) : super(mediaUrls.obs, links.obs);

  factory PrivateChatData.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<MessageLink> links,
  ) {
    final data = doc.data()!;
    return PrivateChatData(
      mediaUrls: List<MessageMedia>.from(
          data['mediaUrls'].map((map) => MessageMedia.fromMap(map))),
      links: links,
    );
  }
}

class GroupChatData extends ChatData {
  RxString name;
  RxString description;
  Rx<String?> photoUrl;
  final List<Member> members;

  GroupChatData({
    required String name,
    required String description,
    String? photoUrl,
    required this.members,
    required List<MessageMedia> mediaUrls,
    required List<MessageLink> links,
  })  : name = name.obs,
        description = description.obs,
        photoUrl = photoUrl.obs,
        super(mediaUrls.obs, links.obs);

  factory GroupChatData.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<Member> members,
    List<MessageLink> links,
  ) {
    final data = doc.data()!;
    return GroupChatData(
      name: data['name'],
      description: data['description'],
      photoUrl: data['photoUrl'],
      members: members,
      mediaUrls: List<MessageMedia>.from(
          data['mediaUrls'].map((map) => MessageMedia.fromMap(map))),
      links: links,
    );
  }

  Map<String, dynamic> toData() {
    return {
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'mediaUrls': media.map((m) => m.photoUrl).toList(),
    };
  }
}

class NonExistentChatData extends ChatData {
  NonExistentChatData() : super(<MessageMedia>[].obs, <MessageLink>[].obs);
}

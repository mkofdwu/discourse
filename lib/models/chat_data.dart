import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/chat_participant.dart';

enum ChatType { private, group }

abstract class ChatData {
  List<Participant> participants;
  String? lastMessageText;

  ChatData({required this.participants, this.lastMessageText});

  Map<String, dynamic> toData();
}

class PrivateChatData extends ChatData {
  PrivateChatData(
      {required List<Participant> participants, String? lastMessageText})
      : super(participants: participants, lastMessageText: lastMessageText);

  factory PrivateChatData.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<Participant> participants,
  ) {
    return PrivateChatData(
      lastMessageText: doc.data()!['lastMessageText'],
      participants: participants,
    );
  }

  @override
  Map<String, dynamic> toData() {
    return {
      'lastMessageText': lastMessageText,
      'participants': participants.map((p) => p.toData()).toList(),
    };
  }
}

class GroupChatData extends ChatData {
  String name;
  String description;
  String? photoUrl;

  GroupChatData({
    required this.name,
    required this.description,
    this.photoUrl,
    required List<Participant> participants,
    String? lastMessageText,
  }) : super(lastMessageText: lastMessageText, participants: participants);

  factory GroupChatData.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<Participant> participants,
  ) {
    final data = doc.data()!;
    return GroupChatData(
      name: data['name'],
      description: data['description'],
      photoUrl: data['photoUrl'],
      participants: participants,
      lastMessageText: data['lastMessageText'],
    );
  }

  @override
  Map<String, dynamic> toData() {
    return {
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'participants': participants.map((p) => p.toData()).toList(),
      'lastMessageText': lastMessageText,
    };
  }
}

class NonExistentChatData extends ChatData {
  NonExistentChatData({
    required List<Participant> participants,
    String? lastMessageText,
  }) : super(lastMessageText: lastMessageText, participants: participants);

  @override
  Map<String, dynamic> toData() {
    return {
      'participants': participants.map((p) => p.toData()).toList(),
      'lastMessageText': lastMessageText,
    };
  }
}

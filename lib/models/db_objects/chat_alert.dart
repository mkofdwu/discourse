import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/chat_log_object.dart';

enum ChatAction {
  editName,
  editDescription,
  editPhoto,
  addMember,
  removeMember,
  memberJoin,
  memberLeave,
  addAdmin,
  removeAdmin,
  transferOwnership,
}

class ChatAlert extends ChatLogObject {
  @override
  final String id;
  String chatId;
  ChatAction action; // used to chose icon
  String content;
  @override
  DateTime sentTimestamp;

  ChatAlert({
    required this.id,
    required this.chatId,
    required this.action,
    required this.content,
    required this.sentTimestamp,
  });

  factory ChatAlert.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatAlert(
      id: doc.id,
      chatId: doc.reference.parent.parent!.id,
      action: ChatAction.values[data['type']],
      content: data['content'],
      sentTimestamp: data['sentTimestamp'].toDate(),
    );
  }

  Map<String, dynamic> toData() {
    return {
      'senderId': null, // to signify that this is an alert not a message
      'type': ChatAction.values.indexOf(action),
      'content': content,
      'sentTimestamp': sentTimestamp,
    };
  }

  @override
  String toString() =>
      'ChatAlert(id: $id, type: $action, content: $content, sentTimestamp: $sentTimestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatAlert &&
        other.id == id &&
        other.action == action &&
        other.content == content &&
        sentTimestamp == sentTimestamp;
  }

  @override
  int get hashCode =>
      id.hashCode ^ action.hashCode ^ content.hashCode ^ sentTimestamp.hashCode;
}

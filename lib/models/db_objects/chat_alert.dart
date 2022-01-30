import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType {
  addMember,
  removeMember,
  memberJoin,
  memberLeave,
  addAdmin,
  removeAdmin,
  transferOwnership,
}

class ChatAlert {
  final String id;
  AlertType type; // used to chose icon
  String content;

  ChatAlert({
    required this.id,
    required this.type,
    required this.content,
  });

  factory ChatAlert.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatAlert(
      id: doc.id,
      type: AlertType.values[data['type']],
      content: data['content'],
    );
  }

  Map<String, dynamic> toData() {
    return {
      'type': AlertType.values.indexOf(type),
      'content': content,
    };
  }

  @override
  String toString() => 'ChatAlert(id: $id, type: $type, content: $content)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatAlert &&
        other.id == id &&
        other.type == type &&
        other.content == content;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ content.hashCode;
}

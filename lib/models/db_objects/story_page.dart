import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType { text, photo }

class StoryPage {
  final String id;
  StoryType type;
  dynamic content; // text or photoUrl
  DateTime sentTimestamp;
  DateTime? editedTimestamp;
  List<String> sentToIds;
  Map<String, DateTime> viewedAt;

  StoryPage({
    required this.id,
    required this.type,
    required this.content,
    required this.sentTimestamp,
    this.editedTimestamp,
    required this.sentToIds,
    required this.viewedAt,
  });

  factory StoryPage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StoryPage(
      id: doc.id,
      type: StoryType.values[data['type']],
      content: data['content'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      editedTimestamp: data['editedTimestamp']?.toDate(),
      sentToIds: List<String>.from(data['sentToIds']),
      viewedAt: Map<String, Timestamp>.from(data['viewedAt'])
          .map((userId, viewedAt) => MapEntry(userId, viewedAt.toDate())),
    );
  }

  Map<String, dynamic> toData() => {
        'type': type.index,
        'content': content,
        'sentTimestamp': sentTimestamp,
        'editedTimestamp': editedTimestamp,
        'sentIds': editedTimestamp,
        'viewedAt': editedTimestamp,
      };
}

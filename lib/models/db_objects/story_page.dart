import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType { text, photo }

class StoryPage {
  final String id;
  StoryType type;
  dynamic content; // text or photoUrl
  DateTime sentTimestamp;
  DateTime? editedTimestamp;

  StoryPage({
    required this.id,
    required this.type,
    required this.content,
    required this.sentTimestamp,
    this.editedTimestamp,
  });

  factory StoryPage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StoryPage(
      id: doc.id,
      type: StoryType.values[data['type']],
      content: data['content'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      editedTimestamp: data['editedTimestamp']?.toDate(),
    );
  }

  Map<String, dynamic> toData() => {
        'type': type.index,
        'content': content,
        'sentTimestamp': sentTimestamp,
        'editedTimestamp': editedTimestamp,
      };
}

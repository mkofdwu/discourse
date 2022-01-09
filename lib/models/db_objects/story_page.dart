import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType { text, photo }

class StoryPage {
  final StoryType type;
  final dynamic content;
  final DateTime sentTimestamp;
  final DateTime? editedTimestamp;

  StoryPage({
    required this.type,
    required this.content,
    required this.sentTimestamp,
    this.editedTimestamp,
  });

  factory StoryPage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StoryPage(
      type: StoryType.values[data['type']],
      content: data['content'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      editedTimestamp: data['editedTimestamp']?.toDate(),
    );
  }
}

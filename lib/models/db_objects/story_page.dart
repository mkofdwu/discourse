import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

enum StoryType { text, photo }

class StoryPage {
  final String id;
  StoryType type;
  dynamic content; // text or photoUrl
  DateTime sentTimestamp;
  DateTime? editedTimestamp;
  List<String> sentToIds;
  List<String> viewedByIds;

  StoryPage({
    required this.id,
    required this.type,
    required this.content,
    required this.sentTimestamp,
    this.editedTimestamp,
    required this.sentToIds,
    required this.viewedByIds,
  });

  bool get viewedByMe => viewedByIds.contains(Get.find<AuthService>().id);

  factory StoryPage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StoryPage(
      id: doc.id,
      type: StoryType.values[data['type']],
      content: data['content'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      editedTimestamp: data['editedTimestamp']?.toDate(),
      sentToIds: List<String>.from(data['sentToIds']),
      viewedByIds: List<String>.from(data['viewedBy']),
    );
  }

  Map<String, dynamic> toData() => {
        'type': type.index,
        'content': content,
        'sentTimestamp': sentTimestamp,
        'editedTimestamp': editedTimestamp,
        'sentToIds': sentToIds,
        'viewedBy': viewedByIds,
      };
}

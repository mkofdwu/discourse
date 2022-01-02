import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/user.dart';

class RepliedMessage {
  final String id;
  DiscourseUser sender;
  Photo? photo;
  String? text;

  RepliedMessage({
    required this.id,
    required this.sender,
    this.photo,
    this.text,
  });

  factory RepliedMessage.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    DiscourseUser sender,
  ) {
    final data = doc.data()!;
    return RepliedMessage(
      id: doc.id,
      sender: sender,
      photo: data['photo'],
      text: data['text'],
    );
  }

  @override
  String toString() =>
      'RepliedMessage(id: $id, sender: $sender, photo: $photo, text: $text)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RepliedMessage &&
        other.id == id &&
        other.sender == sender &&
        other.photo == photo &&
        other.text == text;
  }

  @override
  int get hashCode =>
      id.hashCode ^ sender.hashCode ^ photo.hashCode ^ text.hashCode;
}

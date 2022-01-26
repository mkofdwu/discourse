import 'package:cloud_firestore/cloud_firestore.dart';

class FriendList {
  final String id;
  String name;
  List<String> friendIds;

  FriendList({
    required this.id,
    required this.name,
    required this.friendIds,
  });

  factory FriendList.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FriendList(
      id: doc.id,
      name: data['name'],
      friendIds: List<String>.from(data['friendIds']),
    );
  }

  Map<String, dynamic> toData() {
    return {
      'name': name,
      'friendIds': friendIds,
    };
  }

  @override
  String toString() =>
      'FriendList(id: $id, name: $name, friendIds: $friendIds)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // used in radio group for selecting friends list
    return other is FriendList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ friendIds.hashCode;
}

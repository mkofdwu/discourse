import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/user.dart';

class FriendList {
  final String id;
  String name;
  List<DiscourseUser> friends;

  FriendList({
    required this.id,
    required this.name,
    required this.friends,
  });

  factory FriendList.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<DiscourseUser> friends,
  ) {
    final data = doc.data()!;
    return FriendList(
      id: doc.id,
      name: data['name'],
      friends: friends,
    );
  }

  Map<String, dynamic> toData() {
    return {
      'name': name,
      'friendIds': friends.map((user) => user.id).toList(),
    };
  }

  @override
  String toString() => 'FriendList(id: $id, name: $name, friends: $friends)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // used in radio group for selecting friends list
    return other is FriendList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ friends.hashCode;
}

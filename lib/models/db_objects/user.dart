import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/user_settings.dart';
import 'package:discourse/services/relationships.dart';

class DiscourseUser {
  final String id;
  String email;
  String username;
  String? photoUrl;
  UserSettings settings;
  Map<String, RelationshipStatus> relationships;

  DiscourseUser({
    required this.id,
    required this.email,
    required this.username,
    this.photoUrl,
    required this.settings,
    required this.relationships,
  });

  factory DiscourseUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DiscourseUser(
      id: doc.id,
      email: data['email'],
      username: data['username'],
      photoUrl: data['photoUrl'],
      settings: UserSettings.fromMap(data['settings']),
      relationships: data['relationships'].map(
        (userId, rsIdx) => MapEntry(userId, RelationshipStatus.values[rsIdx]),
      ),
    );
  }

  Map<String, dynamic> toData() {
    return {
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'settings': settings.toMap(),
    };
  }

  @override
  String toString() =>
      'DiscourseUser(id: $id, email: $email, username: $username, photoUrl: $photoUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DiscourseUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

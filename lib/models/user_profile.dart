import 'package:cloud_firestore/cloud_firestore.dart';

// use this in the future when security is enforced (possibly by using an express server)

class UserProfile {
  final String id;
  String username;
  String? photoUrl;
  String? aboutMe;
  DateTime? lastSeen;

  UserProfile({
    required this.id,
    required this.username,
    required this.photoUrl,
    required this.aboutMe,
    required this.lastSeen,
  });

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      id: doc.id,
      username: data['username'],
      photoUrl: data['photoUrl'],
      aboutMe: data['aboutMe'],
      lastSeen: data['lastSeen']?.toDate(),
    );
  }

  @override
  String toString() =>
      'UserProfile(id: $id, username: $username, photoUrl: $photoUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

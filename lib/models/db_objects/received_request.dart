import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/models/db_objects/user.dart';

class ReceivedRequest {
  final String id;
  final DiscourseUser fromUser;
  final RequestType type;
  final dynamic data;
  final bool? accepted;

  ReceivedRequest({
    required this.id,
    required this.fromUser,
    required this.type,
    required this.data,
    required this.accepted,
  });

  factory ReceivedRequest.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc, DiscourseUser fromUser) {
    final data = doc.data()!;
    return ReceivedRequest(
      id: doc.id,
      fromUser: fromUser,
      type: RequestType.values[data['type']],
      data: data['data'],
      accepted: data['accepted'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestType { talk, friend, groupInvite }

class Request {
  String fromUserId;
  String toUserId;
  RequestType type;
  dynamic data;

  Request({
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.data,
  });

  factory Request.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Request(
      fromUserId: data['fromUserId'],
      toUserId: doc.id, // this is how it is
      type: RequestType.values[data['type']],
      data: data['data'],
    );
  }

  Map<String, dynamic> toData() {
    return {
      'fromUserId': fromUserId,
      'type': type.index,
      'data': data,
    };
  }

  @override
  String toString() =>
      'Request(fromUserId: $fromUserId, toUserId: $toUserId, type: $type, data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Request &&
        other.fromUserId == fromUserId &&
        other.toUserId == toUserId &&
        other.type == type &&
        other.data == data;
  }

  @override
  int get hashCode =>
      fromUserId.hashCode ^ toUserId.hashCode ^ type.hashCode ^ data.hashCode;
}

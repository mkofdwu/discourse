enum RequestType { talk, friend, groupInvite }

class UnsentRequest {
  String toUserId;
  RequestType type;
  dynamic data;

  UnsentRequest({
    required this.toUserId,
    required this.type,
    required this.data,
  });

  @override
  String toString() => 'Request(toUserId: $toUserId, type: $type, data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UnsentRequest &&
        other.toUserId == toUserId &&
        other.type == type &&
        other.data == data;
    // dont need to check accepted
  }

  @override
  int get hashCode => toUserId.hashCode ^ type.hashCode ^ data.hashCode;
}

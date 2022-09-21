class MessageMedia {
  final String messageId;
  final String photoUrl;

  MessageMedia(this.messageId, this.photoUrl);

  factory MessageMedia.fromMap(Map<String, dynamic> map) {
    return MessageMedia(map['messageId'], map['url']);
  }

  Map<String, dynamic> toData() {
    return {
      'messageId': messageId,
      'url': photoUrl,
    };
  }
}

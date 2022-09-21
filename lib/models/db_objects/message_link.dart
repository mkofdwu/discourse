import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/utils/url_preview.dart';

class MessageLink {
  String id; // document id
  final String messageId;
  final String url;
  final UrlData data;

  MessageLink(this.id, this.messageId, this.url, this.data);

  factory MessageLink.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MessageLink(
      doc.id,
      data['messageId'],
      data['url'],
      UrlData(
        data['title'],
        data['description'],
        data['photoUrl'],
      ),
    );
  }

  Map<String, dynamic> toData() {
    return {
      'messageId': messageId,
      'url': url,
      'title': data.title,
      'description': data.description,
      'photoUrl': data.photoUrl,
    };
  }
}

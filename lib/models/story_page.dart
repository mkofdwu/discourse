import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StoryPage {
  StoryPage();

  factory StoryPage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    switch (data['type']) {
      case 0:
        return TextPage(
          text: data['text'],
        );
      case 1:
        return PhotoPage(
          photoUrl: data['photoUrl'],
          caption: data['caption'],
        );
      default:
        throw "Invalid story page type: ${data['type']}";
    }
  }
}

class TextPage extends StoryPage {
  String? text;

  TextPage({this.text});
}

class PhotoPage extends StoryPage {
  String photoUrl;
  String? caption;

  PhotoPage({required this.photoUrl, this.caption});
}

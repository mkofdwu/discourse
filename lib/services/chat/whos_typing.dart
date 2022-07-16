import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

class WhosTypingService extends GetxService {
  final _messagesRef = FirebaseFirestore.instance.collection('messages');

  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  Stream<String?> typingTextStream(String chatId) {
    if (chatId == '') return Stream.empty();
    return _messagesRef.doc(chatId).snapshots().asyncMap((doc) async {
      final userIds = List<String>.from(doc.data()!['typing']);
      userIds.remove(_auth.id);
      if (userIds.isEmpty) return null;
      if (userIds.length > 3) return 'Many people are typing...';
      // find usernames
      final usernames =
          await Future.wait<String>(userIds.map<Future<String>>((userId) async {
        return (await _userDb.getUser(userId)).username;
      }));
      if (usernames.length == 1) return usernames.single + ' is typing...';
      return usernames.sublist(0, usernames.length - 1).join(', ') +
          ' and ' +
          usernames.last +
          ' are typing...';
    });
  }

  Future<void> startTyping(String chatId) async {
    await _messagesRef.doc(chatId).update({
      'typing': FieldValue.arrayUnion([_auth.id]),
    });
  }

  Future<void> stopTyping(String chatId) async {
    await _messagesRef.doc(chatId).update({
      'typing': FieldValue.arrayRemove([_auth.id]),
    });
  }
}

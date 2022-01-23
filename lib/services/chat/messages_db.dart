import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BaseMessagesDbService {
  Stream<List<Message>> streamMessages(String chatId, int numMessages);
  Stream<Message> lastMessageStream(String chatId);
  Future<Message> sendMessage(UnsentMessage unsentMessage);
  Future<void> deleteMessages(List<Message> messages);
}

class MessagesDbService extends GetxService implements BaseMessagesDbService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final _messagesRef = FirebaseFirestore.instance.collection('messages');

  Future<Message> _messageFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    final chatId = doc.reference.parent.parent!.id;
    final repliedMessage = data['repliedMessageId'] == null
        ? null
        : await _getRepliedMessage(chatId, data['repliedMessageId']);
    return Message(
      id: doc.id,
      chatId: chatId,
      sender: await _userDb.getUser(data['senderId']),
      repliedMessage: repliedMessage,
      photo: data['photoUrl'] == null ? null : Photo.url(data['photoUrl']),
      text: data['text'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      fromMe: data['senderId'] == _auth.id,
    );
  }

  Future<RepliedMessage> _getRepliedMessage(
    String chatId,
    String messageId,
  ) async {
    final doc = await _messagesRef
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .get();
    final data = doc.data()!;
    return RepliedMessage.fromDoc(
      doc,
      await _userDb.getUser(data['senderId']),
    );
  }

  @override
  Stream<List<Message>> streamMessages(
    String chatId,
    int numMessages,
  ) {
    return _messagesRef
        .doc(chatId)
        .collection('messages')
        .orderBy('sentTimestamp', descending: true)
        .limit(numMessages)
        .snapshots()
        .asyncMap(
          (snapshot) => Future.wait(snapshot.docs.map(
            (doc) => _messageFromDoc(doc),
          )),
        );
  }

  @override
  Stream<Message> lastMessageStream(String chatId) =>
      streamMessages(chatId, 1).asyncMap((list) => list.single);

  Stream<int> numUnreadMessagesStream(String chatId, DateTime? lastReadAt) =>
      // TODO: test with null
      _messagesRef
          .doc(chatId)
          .collection('messages')
          .where('sentTimestamp', isGreaterThan: lastReadAt)
          .snapshots()
          .asyncMap((snapshot) => snapshot.docs.length);

  @override
  Future<Message> sendMessage(UnsentMessage message) async {
    final sentTimestamp = DateTime.now();
    final messageDoc =
        await _messagesRef.doc(message.chatId).collection('messages').add({
      'senderId': _auth.id,
      'repliedMessageId': message.repliedMessage?.id,
      'photoUrl': message.photo?.url,
      'text': message.text,
      'sentTimestamp': Timestamp.fromDate(sentTimestamp),
    });
    return Message(
      id: messageDoc.id,
      chatId: message.chatId,
      sender: _auth.currentUser,
      repliedMessage: message.repliedMessage,
      photo: message.photo,
      text: message.text,
      sentTimestamp: sentTimestamp,
      fromMe: true,
    );
  }

  @override
  Future<void> deleteMessages(List<Message> messages) async {
    for (final message in messages) {
      assert(message.fromMe, "cannot delete someone else's message");
      // message without photo or text is considered deleted
      message.photo = null;
      message.text = null;
      await _messagesRef
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id)
          .update({'photoUrl': null, 'text': null});
    }
  }

  Future<DateTime?> _getLastReadAt(String userId, String chatId) async {
    // TODO FIXME
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .get();
    return doc.data()!['lastReadAt']?.toDate();
  }

  Future<List<DiscourseUser>> getViewedBy(
    UserGroupChat chat,
    Message message,
  ) async {
    final viewedBy = <DiscourseUser>[];
    for (final member in chat.data.members) {
      final lastReadAt = await _getLastReadAt(member.user.id, chat.id);
      if (lastReadAt != null && message.sentTimestamp.isBefore(lastReadAt)) {
        viewedBy.add(member.user);
      }
    }
    return viewedBy;
  }

  Future<List<Photo>> getPhotos(String chatId) async {
    final snapshot = await _messagesRef
        .doc(chatId)
        .collection('messages')
        .where('photoUrl', isNull: false)
        .get();
    return snapshot.docs
        .map((doc) => Photo.url(doc.data()['photoUrl']))
        .toList();
  }
}

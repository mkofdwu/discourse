import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/chat_alert.dart';
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
  Future<ChatLogObject> getMessage(String chatId, String id);
  Stream<List<ChatLogObject>> streamChatLog(String chatId, int numMessages);
  Stream<ChatLogObject> streamLastChatObject(String chatId);
  Future<ChatLogObject> sendMessage(UnsentMessage unsentMessage);
  Future<void> deleteMessages(List<Message> messages);
}

class ChatLogDbService extends GetxService implements BaseMessagesDbService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final _messagesRef = FirebaseFirestore.instance.collection('messages');

  Future<ChatLogObject> _chatObjectFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    if (data['senderId'] == null) {
      return ChatAlert.fromDoc(doc);
    }
    final chatId = doc.reference.parent.parent!.id;
    final repliedMessage = data['repliedMessageId'] == null
        ? null
        : await _getRepliedMessage(chatId, data['repliedMessageId']);
    return Message(
      id: doc.id,
      chatId: chatId,
      sender: await _userDb.getUser(data[
          'senderId']), // hopefully firebase caches these requests, otherwise may have to optimize this
      repliedMessage: repliedMessage,
      photo: data['photoUrl'] == null ? null : Photo.url(data['photoUrl']),
      text: data['text'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      fromMe: data['senderId'] == _auth.id,
    );
  }

  @override
  Future<ChatLogObject> getMessage(String chatId, String id) async {
    final doc =
        await _messagesRef.doc(chatId).collection('messages').doc(id).get();
    return _chatObjectFromDoc(doc);
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
  Stream<List<ChatLogObject>> streamChatLog(
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
            (doc) => _chatObjectFromDoc(doc),
          )),
        );
  }

  @override
  Stream<ChatLogObject> streamLastChatObject(String chatId) =>
      streamChatLog(chatId, 1).asyncMap((list) => list.single);

  Future<List<ChatLogObject>> fetchMoreMessages(
    String chatId,
    DateTime timestamp,
    int numMessages,
    bool fetchOlder,
  ) async {
    // beforeTimestamp is the timestamp of the earliest message fetched (at the top of the chat log)
    final snapshot = await _messagesRef
        .doc(chatId)
        .collection('messages')
        .orderBy('sentTimestamp', descending: fetchOlder)
        // for some reason with fetchOlder = false it also fetches the message with exact timestamp
        // hence I add this small offset
        .startAfter(
            [timestamp.add(Duration(milliseconds: fetchOlder ? -1 : 1))])
        .limit(numMessages)
        .get();
    return Future.wait((fetchOlder ? snapshot.docs.reversed : snapshot.docs)
        .map((doc) => _chatObjectFromDoc(doc)));
  }

  Stream<int> numUnreadMessagesStream(String chatId, DateTime? lastReadAt) =>
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
    DateTime messageTimestamp,
  ) async {
    final viewedBy = <DiscourseUser>[];
    for (final member in chat.groupData.members) {
      final lastReadAt = await _getLastReadAt(member.user.id, chat.id);
      if (lastReadAt != null && messageTimestamp.isBefore(lastReadAt)) {
        viewedBy.add(member.user);
      }
    }
    return viewedBy;
  }

  Future<bool> isViewedByAll(UserChat chat, DateTime messageTimestamp) async {
    if (chat is UserPrivateChat) {
      final lastReadAt = await _getLastReadAt(chat.otherUser.id, chat.id);
      return lastReadAt != null && messageTimestamp.isBefore(lastReadAt);
    } else {
      final viewedBy = await getViewedBy(
        chat as UserGroupChat,
        messageTimestamp,
      );
      return viewedBy.length == chat.groupData.members.length;
    }
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

  Future<void> newAlert(
      String chatId, ChatAction action, String content) async {
    await _messagesRef.doc(chatId).collection('messages').add({
      'senderId': null,
      'type': action.index,
      'content': content,
      'sentTimestamp': Timestamp.now(),
    });
  }

  Future<Message> findNextMessage(
      String chatId, String query, DateTime beforeTimestamp) async {
    final snapshot = await _messagesRef
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNull: false)
        .where(
          'text',
          isGreaterThanOrEqualTo: query,
          isLessThan: query.substring(0, query.length - 1) +
              String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .orderBy('sentTimestamp', descending: true)
        .startAfter([beforeTimestamp])
        .limit(1)
        .get();
    return _chatObjectFromDoc(snapshot.docs.single) as Message;
  }
}

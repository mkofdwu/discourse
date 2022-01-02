import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/chat_data.dart';
import 'package:discourse/models/chat_participant.dart';
import 'package:discourse/models/message.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/models/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDbService extends GetxService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _chatsRef = FirebaseFirestore.instance.collection('chats');

  UserChat? currentChat;

  String get _userId => _auth.currentUser.id;

  Future<List<UserChat>> getUserChats() async {
    final chatsSnapshot =
        await _usersRef.doc(_userId).collection('chats').get();
    final userChats = <UserChat>[];
    for (final doc in chatsSnapshot.docs) {
      // check if chat has messages
      // final messagesSnapshot =
      //     await _chatsRef.doc(doc.id).collection('messages').limit(1).get();
      // if (messagesSnapshot.docs.isEmpty) continue;

      // serialize chat
      userChats.add(await getUserChat(doc));
    }
    return userChats;
  }

  Future<ChatData> getChatData(String chatId) async {
    final doc = await _chatsRef.doc(chatId).get();
    final data = doc.data()!;
    final chatType = ChatType.values[data['type']];
    final participants = await _loadParticipants(
        List<Map<String, dynamic>>.from(data['participants']));
    switch (chatType) {
      case ChatType.private:
        return PrivateChatData.fromDoc(doc, participants);
      case ChatType.group:
        return GroupChatData.fromDoc(doc, participants);
    }
  }

  Future<List<Participant>> _loadParticipants(
      List<Map<String, dynamic>> pMaps) async {
    final participants = <Participant>[];
    for (final pMap in pMaps) {
      participants.add(Participant(
        user: await Get.find<UserDbService>().getUser(pMap['userId']),
        color: Color(pMap['color']),
        role: ParticipantRole.values[pMap['role']],
      ));
    }
    return participants;
  }

  Stream<List<Message>> streamMessages(String chatId, int numMessages) {
    return _chatsRef
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

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getAllMessageDocs(
      String chatId) async {
    final querySnapshot = await _chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('sentTimestamp', descending: false)
        .get();
    return querySnapshot.docs;
  }

  Future<UserChat> getUserChat(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data()!;
    switch (ChatType.values[data['type']]) {
      case ChatType.private:
        return UserPrivateChat(
          id: doc.id,
          lastReadId: data['lastReadId'],
          data: await getChatData(doc.id) as PrivateChatData,
        );
      case ChatType.group:
        return UserGroupChat(
          id: doc.id,
          lastReadId: data['lastReadId'],
          data: await getChatData(doc.id) as GroupChatData,
        );
    }
  }

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
      fromMe: data['senderId'] == _auth.currentUser.id,
    );
  }

  Future<RepliedMessage> _getRepliedMessage(
    String chatId,
    String messageId,
  ) async {
    final doc =
        await _chatsRef.doc(chatId).collection('messages').doc(messageId).get();
    final data = doc.data()!;
    return RepliedMessage.fromDoc(
      doc,
      await _userDb.getUser(data['senderId']),
    );
  }

  Future<Message> getMessage(UserChat userChat, String messageId) async {
    final messageDoc = await _chatsRef
        .doc(userChat.id)
        .collection('messages')
        .doc(messageId)
        .get();
    return _messageFromDoc(messageDoc);
  }

  Future<Message> sendMessage(UnsentMessage message) async {
    await _chatsRef.doc(message.chatId).update({
      'lastMessageText': _auth.currentUser.username + ': ' + message.text!,
    });
    final sentTimestamp = DateTime.now();
    final messageDoc =
        await _chatsRef.doc(message.chatId).collection('messages').add({
      'senderId': _auth.currentUser.id,
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

  Stream<String?> typingTextStream(String chatId) {
    return _chatsRef.doc(chatId).snapshots().asyncMap((doc) async {
      final userIds = List<String>.from(doc.data()!['typing']);
      userIds.remove(_auth.currentUser.id);
      if (userIds.isEmpty) return null;
      if (userIds.length > 5) return 'Many people are typing...';
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
    await _chatsRef.doc(chatId).update({
      'typing': FieldValue.arrayUnion([_userId]),
    });
  }

  Future<void> stopTyping(String chatId) async {
    await _chatsRef.doc(chatId).update({
      'typing': FieldValue.arrayRemove([_userId]),
    });
  }

  Future<UserChat> getChatWith(DiscourseUser user) async {
    final querySnapshot = await _usersRef
        .doc(_userId)
        .collection('chats')
        .where('otherUserId', isEqualTo: user.id)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return NonExistentChat(
        otherUser: user,
        participants: [
          Participant.create(user),
          Participant.create(_auth.currentUser),
        ],
      );
    }
    final doc = querySnapshot.docs.single;
    final data = doc.data();
    return UserPrivateChat(
      id: doc.id,
      lastReadId: data['lastReadId'],
      data: await getChatData(doc.id) as PrivateChatData,
    );
  }

  Future<String> createChatWith(DiscourseUser otherUser) async {
    // for the purposes of this exercise there are no security rules so the chat
    // is created from the client
    // dont need to send a message to create chat.
    // but chats without messages aren't displayed
    final chatDoc = await _chatsRef.add({
      'lastMessageText': null,
    });
    await _usersRef
        .doc(_auth.currentUser.id)
        .collection('chats')
        .doc(chatDoc.id)
        .set({'type': 0, 'lastReadId': null, 'otherUserId': otherUser.id});
    await _usersRef.doc(otherUser.id).collection('chats').doc(chatDoc.id).set({
      'type': 0,
      'lastReadId': null,
      'otherUserId': _auth.currentUser.id,
    });
    return chatDoc.id;
  }

  Future<UserGroupChat> newGroup(GroupChatData data) async {
    final chatDoc = await _chatsRef.add(data.toData());
    for (final participant in data.participants) {
      await _usersRef
          .doc(participant.user.id)
          .collection('chats')
          .doc(chatDoc.id)
          .set({'type': 1, 'lastReadId': null});
    }
    return UserGroupChat(id: chatDoc.id, data: data);
  }

  Future<void> deleteMessages(List<Message> messages) async {
    for (final message in messages) {
      assert(message.fromMe, "cannot delete someone else's message");
      await _chatsRef
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id)
          .delete();
    }
  }

  Future<void> leaveChat(String chatId) async {
    await removeParticipant(chatId, _auth.currentUser.id);
    await _usersRef
        .doc(_auth.currentUser.id)
        .collection('chats')
        .doc(chatId)
        .delete();
  }

  // manage group chat details

  Future<void> updateChatData(String chatId, GroupChatData newData) async {
    await _chatsRef.doc(chatId).update(newData.toData());
  }

  Future<void> addParticipants(
    String chatId,
    List<Participant> participants,
  ) async {
    await _chatsRef.doc(chatId).update({
      'participants': FieldValue.arrayUnion(
        participants.map((p) => p.toData()).toList(),
      ),
    });
  }

  Future<void> removeParticipant(String chatId, String userId) async {
    await _chatsRef.doc(chatId).update({
      'participants.$userId': FieldValue.delete(),
    });
  }

  Future<void> updateParticipantRole(
    String chatId,
    int participantIndex,
    ParticipantRole newRole,
  ) async {
    await _chatsRef.doc(chatId).update({
      'participants.$participantIndex': {'role': newRole.index},
    });
  }
}

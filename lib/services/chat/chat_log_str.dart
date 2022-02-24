import 'dart:convert';

import 'package:discourse/models/db_objects/message.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

abstract class BaseChatLogStrService {
  Future<void> appendToLog(Message message);
  Future<String> chatLogAsStr(String chatId);
}

class ChatLogStrService extends GetxService implements BaseChatLogStrService {
  @override
  Future<void> appendToLog(Message message) async {
    final url =
        Uri.parse('http://159.223.58.1:8000/chat/${message.chatId}/log');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': message.id,
        'senderUsername': message.sender.username,
        'text': message.text,
        'hasPhoto': message.photo != null,
        'sentTimestamp': message.sentTimestamp.millisecondsSinceEpoch,
      }),
    );
  }

  @override
  Future<String> chatLogAsStr(String chatId) async {
    final url = Uri.parse('http://159.223.58.1:8000/chat/$chatId/log');
    final resp = await http.get(url);
    return resp.body;
  }
}

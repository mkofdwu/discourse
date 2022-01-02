import 'package:discourse/models/replied_message.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:get/get.dart';

class RepliedMessageView extends GetView<ChatController> {
  final RepliedMessage message;

  const RepliedMessageView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Palette.light1),
        ),
        child: Text(message.text ?? 'photo'),
      ),
      onTap: () => controller.scrollToMessage(message.id),
    );
  }
}

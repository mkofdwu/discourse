import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeletedMessageView extends StatelessWidget {
  final Message message;

  const DeletedMessageView({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color:
                message.fromMe ? Palette.orange : Get.theme.primaryColorLight,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    FluentIcons.delete_16_regular,
                    color: Get.theme.primaryColor.withOpacity(0.6),
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Deleted message',
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                formatTime(message.sentTimestamp),
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

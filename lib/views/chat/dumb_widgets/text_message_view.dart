import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/message.dart';
import 'package:discourse/utils/format_date_time.dart';

class TextMessageView extends StatelessWidget {
  final Message message;
  final bool isSelected;
  final bool isSent;

  const TextMessageView({
    Key? key,
    required this.message,
    required this.isSelected,
    required this.isSent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: message.fromMe ? Palette.light1 : Palette.light0,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            message.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.text!,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                formatTime(message.sentTimestamp),
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              SizedBox(width: 4),
              if (!isSent) CircularProgressIndicator(strokeWidth: 1),
            ],
          ),
        ],
      ),
    );
  }
}

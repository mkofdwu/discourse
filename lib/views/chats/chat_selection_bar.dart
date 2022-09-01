import 'package:discourse/constants/palette.dart';
import 'package:discourse/views/chats/vertical_dismissible.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class ChatSelectionBar extends StatefulWidget {
  final int numSelected;
  final bool allSelected;
  final Function() onSelectAll;
  final Function() onDismiss;

  const ChatSelectionBar({
    Key? key,
    required this.numSelected,
    required this.allSelected,
    required this.onSelectAll,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<ChatSelectionBar> createState() => _ChatSelectionBarState();
}

class _ChatSelectionBarState extends State<ChatSelectionBar> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: 10,
      right: 10,
      top: widget.numSelected > 0 ? 0 : -70,
      duration: Duration(milliseconds: 300),
      child: VerticalDismissible(
        threshold: -20,
        onDismiss: widget.onDismiss,
        child: Container(
          height: 70,
          padding: const EdgeInsets.only(left: 30, right: 20),
          decoration: BoxDecoration(
            color: Palette.black3,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Text(
                '${widget.numSelected}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              MyIconButton(
                widget.allSelected
                    ? FluentIcons.select_all_on_24_filled
                    : FluentIcons.select_all_on_24_regular,
                onPressed: widget.onSelectAll,
              ),
              SizedBox(width: 4),
              MyIconButton(
                FluentIcons.pin_24_regular,
                onPressed: () {},
              ),
              SizedBox(width: 4),
              MyIconButton(
                FluentIcons.dismiss_24_regular,
                onPressed: widget.onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

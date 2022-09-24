// used to show a popup listing potential people to ping

import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFieldWithPingSuggestions extends StatefulWidget {
  final TextEditingController controller;

  const TextFieldWithPingSuggestions({Key? key, required this.controller})
      : super(key: key);

  @override
  State<TextFieldWithPingSuggestions> createState() =>
      _TextFieldWithPingSuggestionsState();
}

class _TextFieldWithPingSuggestionsState
    extends State<TextFieldWithPingSuggestions> {
  FocusNode? _focusNode;
  ScrollController? _scrollController;
  final _textStyle = TextStyle(
    fontFamily: 'Avenir',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
  OverlayEntry? _currentOverlay;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    KeyboardVisibilityController().onChange.listen((visible) {
      if (!visible) {
        _currentOverlay?.remove();
        _currentOverlay = null;
      }
    });
  }

  @override
  void dispose() {
    _currentOverlay?.remove();
    _scrollController!.dispose();
    _focusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return TextField(
        focusNode: _focusNode!,
        scrollController: _scrollController!,
        controller: widget.controller,
        onChanged: (text) => _onChanged(text, constraints.maxWidth),
        maxLines: 6,
        minLines: 1,
        style: _textStyle,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          border: InputBorder.none,
          hintText: 'Send a message...',
          hintStyle: TextStyle(
            color: Get.theme.primaryColor.withOpacity(0.4),
          ),
        ),
      );
    });
  }

  void _onChanged(String text, double maxWidth) {
    final chat = Get.find<ChatController>().chat;
    if (chat is! UserGroupChat) return;
    final endIndex = widget.controller.selection.baseOffset;
    final index =
        widget.controller.text.lastIndexOf(RegExp(r'(?<=\s|^)@'), endIndex);
    if (index == -1 || index == endIndex) {
      _currentOverlay?.remove();
      _currentOverlay = null;
      return;
    }
    final query =
        widget.controller.text.substring(index + 1, endIndex).toLowerCase();
    final suggestions = chat.groupData.members
        .where((member) => member.user.username.toLowerCase().contains(query))
        .toList();
    if (suggestions.isEmpty) {
      _currentOverlay?.remove();
      _currentOverlay = null;
      return;
    }

    // show popup
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: widget.controller.text.substring(0, index),
        style: _textStyle,
      ),
      maxLines: null,
    );
    painter.layout(maxWidth: maxWidth);
    final offset =
        painter.getOffsetForCaret(TextPosition(offset: index), Rect.zero);

    _currentOverlay?.remove();
    _currentOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          top:
              _focusNode!.offset.dy + offset.dy - _scrollController!.offset - 8,
          left: _focusNode!.offset.dx + offset.dx - 8,
          child: FractionalTranslation(
            translation: Offset(0, -1),
            child: Material(
              color: Color(0xFF3a3a3a),
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: _buildSuggestionsList(suggestions, (Member member) {
                widget.controller.text = widget.controller.text
                    .replaceRange(index, endIndex, '@${member.user.username}');
                widget.controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: index + member.user.username.length + 1),
                );
                _currentOverlay!.remove();
                _currentOverlay = null;
              }),
            ),
          ),
        );
      },
    );
    Overlay.of(context)?.insert(_currentOverlay!);
  }

  Widget _buildSuggestionsList(
    List<Member> suggestions,
    Function(Member) onSelect,
  ) {
    if (suggestions.length > 5) {
      suggestions = suggestions.sublist(0, 5);
    }
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final member in suggestions)
            PressedBuilder(
              onPressed: () => onSelect(member),
              builder: (pressed) => AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.fromLTRB(12, 6, 20, 6),
                color: Colors.white.withOpacity(pressed ? 0.1 : 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhotoOrIcon(
                      size: 28,
                      iconSize: 14,
                      photoUrl: member.user.photoUrl,
                      placeholderIcon: FluentIcons.person_12_regular,
                    ),
                    SizedBox(width: 12),
                    Text(
                      member.user.username,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/vertical_dismissible.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class SelectionOptionsBar extends StatelessWidget {
  final int numSelected;
  final Map<IconData, Function()> options;
  final Function() onDismiss;

  const SelectionOptionsBar({
    Key? key,
    required this.numSelected,
    required this.options,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300),
      tween: Tween(
        begin: Offset(0, -1),
        end: numSelected > 0 ? Offset(0, 0) : Offset(0, -1),
      ),
      builder: (context, offset, child) {
        return FractionalTranslation(
          translation: offset as Offset,
          child: VerticalDismissible(
            threshold: -20,
            onDismiss: onDismiss,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Palette.black3,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: Offset(0, 12),
                    blurRadius: 30,
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 20, 20),
                  child: Row(
                    children: [
                      Text(
                        '$numSelected',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                      ...options
                          .map((iconData, onPressed) => MapEntry(
                                iconData,
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: MyIconButton(
                                    iconData,
                                    onPressed: onPressed,
                                  ),
                                ),
                              ))
                          .values,
                      MyIconButton(
                        FluentIcons.dismiss_24_regular,
                        onPressed: onDismiss,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

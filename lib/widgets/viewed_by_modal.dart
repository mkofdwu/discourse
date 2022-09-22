import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/utils/animation.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewedByModal extends StatelessWidget {
  final List<DiscourseUser> viewedBy;
  final String placeholderMessage;

  const ViewedByModal({
    Key? key,
    required this.viewedBy,
    required this.placeholderMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: viewedBy.isEmpty ? 0.6 : 1,
        builder: (context, controller) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final extent = constraints.maxHeight / Get.height;
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: lerp(8, 0, extent, after: 0.8),
                ),
                decoration: BoxDecoration(
                  color: Get.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(lerp(10, 0, extent, after: 0.86)),
                    topRight: Radius.circular(lerp(10, 0, extent, after: 0.86)),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
                  child: Column(
                    children: [
                      Text(
                        'Viewed by',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 30),
                      if (viewedBy.isEmpty) ...[
                        SizedBox(height: 30),
                        Image.asset(
                          'assets/images/undraw_book.png',
                          width: 160,
                        ),
                        SizedBox(height: 40),
                        Text(
                          placeholderMessage,
                          style: TextStyle(
                            color: Get.theme.primaryColor.withOpacity(0.6),
                          ),
                        ),
                      ] else
                        ...viewedBy
                            .map((user) => MyListTile(
                                  title: user.username,
                                  subtitle: null,
                                  photoUrl: user.photoUrl,
                                  iconData: FluentIcons.person_24_regular,
                                  compact: true,
                                ))
                            .toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

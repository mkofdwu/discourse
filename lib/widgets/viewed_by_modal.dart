import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/utils/animation.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewedByModal extends StatelessWidget {
  final Map<DiscourseUser, DateTime> viewedAt;

  const ViewedByModal({Key? key, required this.viewedAt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: viewedAt.isEmpty ? 0.6 : 1,
        builder: (context, controller) {
          return LayoutBuilder(builder: (context, constraints) {
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
                    if (viewedAt.isEmpty) ...[
                      SizedBox(height: 30),
                      Image.asset(
                        'assets/images/undraw_book.png',
                        width: 160,
                      ),
                      SizedBox(height: 40),
                      Text(
                        'No one has seen your story yet',
                        style: TextStyle(
                          color: Get.theme.primaryColor.withOpacity(0.6),
                        ),
                      ),
                    ] else
                      ...viewedAt
                          .map((user, timestamp) => MapEntry(
                              user,
                              MyListTile(
                                title: user.username,
                                // removed after 24 hours so its either today or ystd
                                subtitle: timeTodayOrYesterday(timestamp),
                                photoUrl: user.photoUrl,
                                iconData: FluentIcons.person_24_regular,
                              )))
                          .values,
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'blocked_users_controller.dart';

class BlockedUsersView extends StatelessWidget {
  const BlockedUsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BlockedUsersController>(
      init: BlockedUsersController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Blocked users'),
        body: FutureBuilder<List<DiscourseUser>>(
          future: controller.blockedUsers(),
          initialData: const [],
          builder: (context, snapshot) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                children: snapshot.data!
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: MyListTile(
                                iconData: FluentIcons.person_16_regular,
                                title: user.username,
                                subtitle: null,
                                photoUrl: user.photoUrl,
                              ),
                            ),
                            SizedBox(width: 16),
                            OpacityFeedback(
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Palette.black3,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Icon(
                                    FluentIcons.arrow_undo_16_regular,
                                    size: 16,
                                  ),
                                ),
                              ),
                              onPressed: () => controller.unblockUser(user),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

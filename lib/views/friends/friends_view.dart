import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'friends_controller.dart';

class FriendsView extends StatelessWidget {
  const FriendsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendsController>(
      init: FriendsController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Friends'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
          child: Column(
            children: controller.myFriends
                .map((user) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MyListTile(
                        title: user.username,
                        subtitle: user.aboutMe,
                        photoUrl: user.photoUrl,
                        iconData: FluentIcons.person_16_regular,
                        suffixIcons: {
                          FluentIcons.more_vertical_20_regular: () =>
                              controller.showFriendOptions(user)
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

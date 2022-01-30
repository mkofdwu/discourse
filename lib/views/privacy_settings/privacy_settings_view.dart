import 'package:discourse/models/db_objects/friend_list.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/radio_group.dart';
import 'package:discourse/widgets/setting_tile.dart';
import 'package:discourse/widgets/switch.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'privacy_settings_controller.dart';

class PrivacySettingsView extends StatelessWidget {
  const PrivacySettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrivacySettingsController>(
      global: false,
      init: PrivacySettingsController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Privacy Settings'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Column(
            children: [
              SettingTile(
                name: 'Public account',
                description:
                    'Allow anyone on this app to find you and view your posts',
                trailing: MySwitch(
                  defaultValue: true,
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 16),
              SettingTile(
                name: 'Read receipts',
                description: 'Read receipts are always sent in group chats',
                trailing: MySwitch(
                  defaultValue: true,
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 16),
              SettingTile(
                name: 'Story privacy',
                description: 'Control who can view your stories',
                trailing: SizedBox.shrink(),
                bottom: Column(
                  children: [
                    (() {
                      final lists = Map<FriendList, String>.fromEntries(
                          controller.myFriendLists.map((friendList) =>
                              MapEntry(friendList, friendList.name)));
                      return RadioGroup<FriendList?>(
                        options: {null: 'All friends'}..addAll(lists),
                        defaultValue: controller.defaultFriendList,
                        onSelect: controller.changeDefaultFriendList,
                        onEdit: controller.editFriendList,
                      );
                    })(),
                    SizedBox(height: 8),
                    MyButton(
                      text: 'Add friend list',
                      fillWidth: true,
                      isPrimary: false,
                      prefixIcon: FluentIcons.add_16_filled,
                      onPressed: controller.toNewFriendList,
                    ),
                    SizedBox(height: 6),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SettingTile(
                name: 'Blocked users',
                onPressed: controller.toBlockedUsers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

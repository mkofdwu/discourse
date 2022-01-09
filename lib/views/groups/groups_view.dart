import 'package:discourse/views/groups/groups_controller.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupsController>(
      init: GroupsController(),
      builder: (controller) => Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(FluentIcons.add_20_filled, size: 20),
          onPressed: () {},
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Friend groups',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    // TODO: show if has new activity
                    Icon(FluentIcons.alert_24_regular),
                  ],
                ),
                SizedBox(height: 40),
                _buildGroupsList(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsList(GroupsController controller) => Column(
        children: [
          MyListTile(
            title: 'Tree family',
            subtitle: 'You: the quick brown fox jumps over the lazy dog',
            photoUrl:
                'https://images.unsplash.com/photo-1641579281152-e5d633aa3775?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1632&q=80',
            iconData: FluentIcons.people_community_16_regular,
            suffixIcons: {
              FluentIcons.more_vertical_20_regular: controller.showGroupOptions,
            },
            onPressed: () {},
          ),
        ],
      );
}

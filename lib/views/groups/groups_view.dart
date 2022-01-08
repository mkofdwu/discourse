import 'package:discourse/views/groups/groups_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupsController>(
      init: GroupsController(),
      builder: (controller) => Container(),
    );
  }
}

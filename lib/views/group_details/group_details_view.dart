import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'group_details_controller.dart';

class GroupDetailsView extends StatelessWidget {
  final UserGroupChat chat;

  const GroupDetailsView({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupDetailsController>(
      init: GroupDetailsController(),
      builder: (controller) => Scaffold(),
    );
  }
}

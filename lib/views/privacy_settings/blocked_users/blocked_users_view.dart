import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'blocked_users_controller.dart';

class BlockedUsersView extends StatelessWidget {
  const BlockedUsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BlockedUsersController>(
      init: BlockedUsersController(),
      builder: (controller) => Scaffold(),
    );
  }
}

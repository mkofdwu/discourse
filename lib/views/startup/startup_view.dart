import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'startup_controller.dart';

class StartupView extends StatelessWidget {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StartupController>(
      global: false,
      init: StartupController(),
      builder: (StartupController controller) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

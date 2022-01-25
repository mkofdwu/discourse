import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'explore_controller.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      init: ExploreController(),
      builder: (controller) => Scaffold(),
    );
  }
}

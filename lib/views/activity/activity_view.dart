import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/request_controller.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/widgets/animated_list.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/loading.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'activity_controller.dart';

class ActivityListTile extends StatelessWidget {
  final ActivityController activityController;
  final RequestController rq;
  final Function() animateRemove;

  const ActivityListTile({
    Key? key,
    required this.activityController,
    required this.rq,
    required this.animateRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyListTile(
      increaseWidthFactor: false,
      iconData: rq.request.type == RequestType.groupInvite
          ? FluentIcons.people_community_16_regular
          : FluentIcons.person_16_regular,
      title: rq.title,
      subtitle: rq.subtitle,
      photoUrl: rq.photoUrl,
      extraWidgets: [
        _buildCircleButton(
          FluentIcons.checkmark_16_regular,
          Palette.orange,
          () {
            activityController.respondToRequest(rq, true);
            animateRemove();
          },
        ),
        SizedBox(width: 12),
        _buildCircleButton(
          FluentIcons.dismiss_16_regular,
          Palette.black3,
          () {
            activityController.respondToRequest(rq, false);
            animateRemove();
          },
        ),
      ],
    );
  }

  Widget _buildCircleButton(
    IconData iconData,
    Color color,
    Function() onPressed,
  ) =>
      OpacityFeedback(
        onPressed: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(child: Icon(iconData, size: 16)),
        ),
      );
}

class ActivityView extends StatefulWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final _listAnimationController = ListAnimationController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivityController>(
      init: ActivityController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(
          title: 'Activity',
          actions: {
            FluentIcons.more_vertical_20_regular: controller.showOptions,
          },
        ),
        body: controller.loading
            ? Center(child: Loading())
            : controller.requestControllers.isEmpty
                ? _buildPlaceholder()
                : MyAnimatedList(
                    controller: _listAnimationController,
                    initialList: controller.requestControllers,
                    listTileBuilder: (i, rq) {
                      return ActivityListTile(
                        activityController: controller,
                        rq: rq,
                        animateRemove: () =>
                            _listAnimationController.animateRemove(i, rq),
                      );
                    },
                  ),
      ),
    );
  }

  Padding _buildPlaceholder() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/undraw_no_data.png',
              width: 160,
            ),
            SizedBox(height: 48),
            Text(
              'Nothing here yet. Friend requests or group invites will appear here',
              style: TextStyle(
                color: Get.theme.primaryColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
          ],
        ),
      );
}

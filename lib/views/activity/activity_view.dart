import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'activity_controller.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivityController>(
      init: ActivityController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Activity'),
        body: controller.requestControllers.isEmpty && !controller.loading
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/undraw no data.png',
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
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  children: controller.requestControllers
                      .map(
                        (rq) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: MyListTile(
                                  iconData: rq.request.type ==
                                          RequestType.groupInvite
                                      ? FluentIcons.people_community_16_regular
                                      : FluentIcons.person_16_regular,
                                  title: rq.title,
                                  subtitle: rq.subtitle,
                                  photoUrl: rq.photoUrl,
                                ),
                              ),
                              SizedBox(width: 16),
                              _buildCircleButton(
                                FluentIcons.checkmark_16_regular,
                                Palette.orange,
                                () => controller.respondToRequest(rq, true),
                              ),
                              SizedBox(width: 12),
                              _buildCircleButton(
                                FluentIcons.dismiss_16_regular,
                                Palette.black3,
                                () => controller.respondToRequest(rq, false),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )),
      ),
    );
  }

  Widget _buildCircleButton(
    IconData iconData,
    Color color,
    Function() onPressed,
  ) =>
      OpacityFeedback(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(child: Icon(iconData, size: 16)),
        ),
        onPressed: onPressed,
      );
}

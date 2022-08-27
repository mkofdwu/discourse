import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/request_controller.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'rejected_requests_controller.dart';

class RejectedRequestListTile extends AnimatedWidget {
  final RejectedRequestsController controller;
  final RequestController rq;
  final Function() animateRemove;

  const RejectedRequestListTile({
    Key? key,
    required this.controller,
    required this.rq,
    required Animation<double> animation,
    required this.animateRemove,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: (listenable as Animation<double>),
      child: FadeTransition(
        opacity: (listenable as Animation<double>),
        child: MyListTile(
          increaseWidthFactor: false,
          iconData: rq.request.type == RequestType.groupInvite
              ? FluentIcons.people_community_16_regular
              : FluentIcons.person_16_regular,
          title: rq.title,
          subtitle: rq.subtitle,
          photoUrl: rq.photoUrl,
          extraWidgets: [
            _buildCircleButton(
              FluentIcons.arrow_undo_16_regular,
              Palette.black3,
              () {
                controller.undoRejection(rq);
                animateRemove();
              },
            ),
          ],
        ),
      ),
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

class RejectedRequestsView extends StatelessWidget {
  const RejectedRequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RejectedRequestsController>(
      init: RejectedRequestsController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Rejected requests'),
        body: controller.requestControllers.isEmpty && !controller.loading
            ? _buildPlaceholder()
            : AnimatedList(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                initialItemCount: controller.requestControllers.length,
                itemBuilder: (context, index, animation) {
                  final rq = controller.requestControllers[index];
                  return RejectedRequestListTile(
                    controller: controller,
                    rq: rq,
                    animation: animation,
                    animateRemove: () {
                      AnimatedList.of(context).removeItem(
                        index,
                        (context, animation) => RejectedRequestListTile(
                          controller: controller,
                          rq: rq,
                          animation: animation,
                          animateRemove: () {},
                        ),
                      );
                    },
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
              'Nothing here yet. Rejected requests will appear here',
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

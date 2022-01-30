import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'date_selector_controller.dart';

class DateSelectorView extends StatelessWidget {
  final String title;

  const DateSelectorView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DateSelectorController>(
      init: DateSelectorController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: title),
        body: Column(
          children: [
            _buildCalendar(controller),
            MyButton(text: 'Submit', onPressed: controller.submit),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(DateSelectorController controller) => Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
              Spacer(),
              OpacityFeedback(
                onPressed: controller.prevMonth,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Icon(FluentIcons.chevron_left_16_regular, size: 16),
                  ),
                ),
              ),
              SizedBox(width: 12),
              OpacityFeedback(
                onPressed: controller.nextMonth,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Palette.black3,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(FluentIcons.chevron_right_16_filled, size: 16),
                  ),
                ),
              ),
            ],
          )
        ],
      );
}

import 'package:discourse/constants/month_names.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/pressed_builder.dart';
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildCalendarTop(controller),
              ),
              _buildCalendarMain(controller),
              Spacer(),
              MyButton(text: 'Submit', onPressed: controller.submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarTop(DateSelectorController controller) => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OpacityFeedback(
                    onPressed: controller.chooseYear,
                    child: Text(
                      controller.currentYear.toString(),
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  OpacityFeedback(
                    onPressed: controller.chooseMonth,
                    child: Text(
                      monthNames[controller.currentMonth],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
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
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Text(day))
                .toList(),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 1,
            color: Get.theme.primaryColor.withOpacity(0.1),
          ),
          SizedBox(height: 12),
        ],
      );

  Widget _buildCalendarMain(DateSelectorController controller) => SizedBox(
        height: 290,
        child: PageView.builder(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, i) {
            final month = controller.indexToMonth(i);
            final year = controller.indexToYear(i);
            final offset = controller.startWeekday(month, year);
            return GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: List.generate(
                controller.numDaysInMonth(month, year) + offset,
                (j) => j < offset
                    ? Container()
                    : _buildDate(
                        controller,
                        DateTime(year, month + 1, j - offset + 1),
                      ),
              ),
            );
          },
        ),
      );

  Widget _buildDate(DateSelectorController controller, DateTime date) {
    final isSelected = date == controller.selectedDate;
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    return PressedBuilder(
      onPressed: () => controller.selectDate(date),
      builder: (pressed) => Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Palette.orange.withOpacity(0.1)
              : pressed
                  ? Palette.black2
                  : null,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(
                  color: isSelected
                      ? Palette.orange.withOpacity(0.6)
                      : Get.theme.primaryColor.withOpacity(0.2))
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: isSelected ? Palette.orange : Get.theme.primaryColor,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

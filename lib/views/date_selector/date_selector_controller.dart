import 'package:discourse/constants/month_names.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const bigNumber = 9999;
final initialMonth = DateTime.now().month - 1;
final initialYear = DateTime.now().year;

const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

class DateSelectorController extends GetxController {
  final pageController = PageController(initialPage: bigNumber);

  int currentMonth = initialMonth;
  int currentYear = initialYear;
  DateTime? selectedDate;

  // returns number from 0 to 6 (0 being sunday)
  int startWeekday(int month, int year) =>
      DateTime(year, month + 1, 1).weekday % 7;

  int numDaysInMonth(int month, int year) {
    if (month == 1) {
      if (year % 400 == 0) return 29;
      if (year % 100 == 0) return 28;
      if (year % 4 == 0) return 29;
      return 28;
    }
    return daysInMonth[month];
  }

  int indexToMonth(int index) => (index - bigNumber + initialMonth) % 12;
  int indexToYear(int index) {
    final numMonths =
        index - bigNumber + initialMonth; // since the start of the initial year
    int diff = numMonths ~/ 12;
    if (numMonths < 0) diff -= 1;
    return initialYear + diff;
  }

  void prevMonth() {
    pageController.previousPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void nextMonth() {
    pageController.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    currentMonth = indexToMonth(index);
    currentYear = indexToYear(index);
    update();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    update();
  }

  void chooseYear() async {
    final yearStr = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Select year',
      choices: List.generate(10, (i) => (initialYear - i).toString()),
    ));
    if (yearStr == null) return;
    final year = int.parse(yearStr);
    pageController
        .jumpToPage(bigNumber + (year - initialYear) * 12 + currentMonth);
  }

  void chooseMonth() async {
    final monthStr = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Select month',
      choices: monthNames,
    ));
    if (monthStr == null) return;
    final month = monthNames.indexOf(monthStr);
    pageController
        .jumpToPage(pageController.page!.toInt() + month - currentMonth);
  }

  void submit() {
    Get.back(result: selectedDate);
  }
}

import 'package:get/get.dart';

class DateSelectorController extends GetxController {
  DateTime? selectedDate;

  void prevMonth() {}

  void nextMonth() {}

  void submit() {
    Get.back(result: selectedDate);
  }
}

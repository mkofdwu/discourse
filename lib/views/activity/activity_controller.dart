import 'package:discourse/models/request_controller.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

import 'rejected_requests/rejected_requests_view.dart';

class ActivityController extends GetxController {
  final _requests = Get.find<RequestsService>();

  bool loading = false;
  List<RequestController> requestControllers = [];

  @override
  void onReady() async {
    loading = true;
    update();
    requestControllers = (await _requests.myRequests())
        .map((request) => RequestController.create(request))
        .toList();
    await Future.wait(requestControllers.map((h) => h.loadData()));
    loading = false;
    update();
  }

  void respondToRequest(RequestController rq, bool accept) async {
    await (accept ? rq.acceptRequest() : rq.rejectRequest());
    requestControllers.remove(rq);
    update();
  }

  void showOptions() async {
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Options',
      choices: const ['Rejected requests'],
    ));
    if (choice != null && choice == 'Rejected requests') {
      Get.to(RejectedRequestsView());
    }
  }
}
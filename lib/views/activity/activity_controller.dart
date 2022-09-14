import 'package:discourse/models/request_controller.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/widgets/animated_list.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

import 'rejected_requests/rejected_requests_view.dart';

class ActivityController extends GetxController {
  final _requests = Get.find<RequestsService>();

  RxBool loading = false.obs;
  final requestControllers = <RequestController>[].obs;
  final listAnimation = ListAnimationController();

  @override
  void onReady() async {
    loading.value = true;
    requestControllers.addAll((await _requests.myRequests())
        .map((request) => RequestController.create(request)));
    await Future.wait(requestControllers.map((h) => h.loadData()));
    loading.value = false;
  }

  void respondToRequest(RequestController rq, bool accept) async {
    await (accept ? rq.acceptRequest() : rq.rejectRequest());
    requestControllers.remove(rq);
  }

  void addRequest(RequestController rq) {
    // called from rejected requests controller
    requestControllers.add(rq);
    if (requestControllers.length > 1) {
      listAnimation.animateInsert(requestControllers.length - 1);
    }
  }

  void showOptions() async {
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Options',
      choices: const ['Rejected requests'],
    ));
    if (choice != null && choice == 'Rejected requests') {
      Get.to(() => RejectedRequestsView());
    }
  }
}

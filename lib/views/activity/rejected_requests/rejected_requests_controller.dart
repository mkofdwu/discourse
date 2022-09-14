import 'package:discourse/models/request_controller.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/views/activity/activity_controller.dart';
import 'package:get/get.dart';

class RejectedRequestsController extends GetxController {
  final _requests = Get.find<RequestsService>();

  RxBool loading = false.obs;
  final requestControllers = <RequestController>[].obs;

  @override
  void onReady() async {
    loading.value = true;
    requestControllers.addAll((await _requests.requestsIRejected())
        .map((request) => RequestController.create(request)));
    await Future.wait(requestControllers.map((h) => h.loadData()));
    loading.value = false;
  }

  void undoRejection(RequestController rq) async {
    await _requests.undoRejection(rq.request);
    requestControllers.remove(rq);
    Get.find<ActivityController>().addRequest(rq);
  }
}

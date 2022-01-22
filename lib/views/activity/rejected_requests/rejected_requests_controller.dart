import 'package:discourse/models/request_controller.dart';
import 'package:discourse/services/requests.dart';
import 'package:get/get.dart';

class RejectedRequestsController extends GetxController {
  final _requests = Get.find<RequestsService>();

  bool loading = false;
  List<RequestController> requestControllers = [];

  @override
  void onReady() async {
    loading = true;
    update();
    requestControllers = (await _requests.requestsIRejected())
        .map((request) => RequestController.create(request))
        .toList();
    await Future.wait(requestControllers.map((h) => h.loadData()));
    loading = false;
    update();
  }

  void undoRejection(RequestController rq) async {
    await _requests.undoRejection(rq.request);
    requestControllers.remove(rq);
    update();
  }
}

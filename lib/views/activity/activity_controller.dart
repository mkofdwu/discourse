import 'package:discourse/models/request_controller.dart';
import 'package:discourse/services/requests.dart';
import 'package:get/get.dart';

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
}

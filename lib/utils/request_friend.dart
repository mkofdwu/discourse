import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/services/requests.dart';
import 'package:get/get.dart';

Future<void> requestFriend(String userId) async {
  await Get.find<RequestsService>().sendRequest(UnsentRequest(
    toUserId: userId,
    type: RequestType.friend,
    data: null,
  ));
  Get.snackbar('Success', 'Your friend request has been sent');
}

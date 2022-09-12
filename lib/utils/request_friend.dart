import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/widgets/snack_bar.dart';
import 'package:get/get.dart';

Future<void> requestFriend(String userId) async {
  await Get.find<RequestsService>().sendRequest(UnsentRequest(
    toUserId: userId,
    type: RequestType.friend,
    data: null,
  ));
  showSnackBar(
    type: SnackBarType.success,
    message: 'Your friend request has been sent',
  );
}

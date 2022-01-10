import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

abstract class BaseRequestsService {
  Future<List<Request>> getRequests();
  Future<void> sendRequest(Request request);
  Future<void> acceptRequest(Request request);
  Future<void> rejectRequest(Request request);
}

class RequestsService extends GetxService implements BaseRequestsService {
  final _requestsRef = FirebaseFirestore.instance.collection('requests');

  final _auth = Get.find<AuthService>();

  @override
  Future<List<Request>> getRequests() async {
    final requestsSnapshot = await _requestsRef
        .doc(_auth.currentUser.id)
        .collection('requests')
        .get();
    return requestsSnapshot.docs.map((doc) => Request.fromDoc(doc)).toList();
  }

  @override
  Future<void> acceptRequest(Request request) {
    // TODO: implement acceptRequest
    throw UnimplementedError();
  }

  @override
  Future<void> rejectRequest(Request request) {
    // TODO: implement rejectRequest
    throw UnimplementedError();
  }

  @override
  Future<void> sendRequest(Request request) {
    // TODO: implement sendRequest
    throw UnimplementedError();
  }
}

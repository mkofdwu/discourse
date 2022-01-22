import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/request.dart';
import 'package:discourse/models/db_objects/received_request.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BaseRequestsService {
  Future<List<ReceivedRequest>> myRequests();
  Future<bool> hasNewRequests();
  Future<void> sendRequest(Request request);
  Future<void> acceptRequest(ReceivedRequest request);
  Future<void> rejectRequest(ReceivedRequest request);
  Future<List<ReceivedRequest>> requestsIRejected();
  Future<void> undoRejection(ReceivedRequest request);
}

class RequestsService extends GetxService implements BaseRequestsService {
  final _requestsRef = FirebaseFirestore.instance.collection('requests');

  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  @override
  Future<List<ReceivedRequest>> myRequests() async {
    final requestsSnapshot = await _requestsRef
        .doc(_auth.id)
        .collection('requests')
        .where('accepted', isNull: true)
        .get();
    return Future.wait(requestsSnapshot.docs.map((doc) async {
      final fromUser = await _userDb.getUser(doc.data()['fromUserId']);
      return ReceivedRequest.fromDoc(doc, fromUser);
    }));
  }

  @override
  Future<bool> hasNewRequests() async {
    final requestsSnapshot = await _requestsRef
        .doc(_auth.id)
        .collection('requests')
        .where('accepted', isNull: true)
        .limit(1)
        .get();
    return requestsSnapshot.docs.length == 1;
  }

  @override
  Future<void> sendRequest(Request request) async {
    // TODO: check if blocked or the same request has already been sent
    await _requestsRef.doc(request.toUserId).collection('requests').add({
      'fromUserId': _auth.id,
      'type': request.type.index,
      'data': request.data,
      'accepted': null,
    });
  }

  Future<void> _setRequestStatus(
      ReceivedRequest request, bool? accepted) async {
    await _requestsRef
        .doc(_auth.id)
        .collection('requests')
        .doc(request.id)
        .update({'accepted': accepted});
  }

  @override
  Future<void> acceptRequest(ReceivedRequest request) =>
      _setRequestStatus(request, true);

  @override
  Future<void> rejectRequest(ReceivedRequest request) =>
      _setRequestStatus(request, false);

  @override
  Future<List<ReceivedRequest>> requestsIRejected() async {
    final requestsSnapshot = await _requestsRef
        .doc(_auth.id)
        .collection('requests')
        .where('accepted', isEqualTo: false)
        .get();
    return Future.wait(requestsSnapshot.docs.map((doc) async {
      final fromUser = await _userDb.getUser(doc.data()['fromUserId']);
      return ReceivedRequest.fromDoc(doc, fromUser);
    }));
  }

  @override
  Future<void> undoRejection(ReceivedRequest request) =>
      _setRequestStatus(request, null);
}

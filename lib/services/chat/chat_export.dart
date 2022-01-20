import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/user_db.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:discourse/utils/format_date_time.dart';

class ChatExportService extends GetxService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  Future<void> exportChat(UserChat chat) async {
    final googleSignIn =
        GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final account = await googleSignIn.signIn() as GoogleSignInAccount;
    final authHeaders = await account.authHeaders;
    final driveApi = drive.DriveApi(_GoogleAuthClient(authHeaders));
    final chatHistoryString = await _stringifyChatHistory(chat);
    final mediaStream =
        Stream.value(chatHistoryString.codeUnits).asBroadcastStream();
    final media = drive.Media(mediaStream, chatHistoryString.length);
    final driveFile = drive.File();
    driveFile.title = 'simple chat - ${chat.title}.txt';
    await driveApi.files.insert(driveFile, uploadMedia: media);
  }

  Future<String> _stringifyChatHistory(UserChat chat) async {
    var chatHistory = '';
    final messageDocs = await _getAllMessageDocs(chat.id);
    for (final messageDoc in messageDocs) {
      final data = messageDoc.data()!;
      final DateTime sentTimestamp = data['sentTimestamp'].toDate();
      final sentOn =
          formatDate(sentTimestamp) + ' ' + formatTime(sentTimestamp);
      final senderUsername = await _getSenderUserame(data['senderId'], chat);
      final photoStr = data['photoUrl'] == null ? '' : 'photo';
      final text = data['text'];
      chatHistory += '$sentOn $senderUsername: $photoStr $text\n';
    }
    return chatHistory;
  }

  Future<String> _getSenderUserame(String senderId, UserChat chat) async {
    if (senderId == _auth.id) return _auth.currentUser.username;
    if (chat is UserPrivateChat) {
      return chat.otherUser.username;
    }
    if (chat is UserGroupChat) {
      final user = await _userDb.getUser(senderId);
      return user.username;
    }
    throw 'invalid chat type: ${chat.runtimeType}';
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _getAllMessageDocs(
      String chatId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentTimestamp', descending: false)
        .get();
    return querySnapshot.docs;
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

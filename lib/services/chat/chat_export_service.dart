import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';
import 'package:discourse/models/user_chat.dart';
import 'package:discourse/services/chat_db.dart';
import 'package:discourse/services/user_db.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:discourse/utils/format_date_time.dart';

class ChatExportService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _chatApi = Get.find<ChatDbService>();

  Future<void> exportChat(UserChat userChat) async {
    final googleSignIn =
        GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final account = await googleSignIn.signIn() as GoogleSignInAccount;
    final authHeaders = await account.authHeaders;
    final driveApi = drive.DriveApi(_GoogleAuthClient(authHeaders));
    final chatHistoryString = await _stringifyChatHistory(userChat);
    final mediaStream =
        Stream.value(chatHistoryString.codeUnits).asBroadcastStream();
    final media = drive.Media(mediaStream, chatHistoryString.length);
    final driveFile = drive.File();
    driveFile.title = 'simple chat - ${userChat.title}.txt';
    await driveApi.files.insert(driveFile, uploadMedia: media);
  }

  Future<String> _stringifyChatHistory(UserChat userChat) async {
    var chatHistory = '';
    final messageDocs = await _chatApi.getAllMessageDocs(userChat.id);
    for (final messageDoc in messageDocs) {
      final data = messageDoc.data()!;
      final DateTime sentTimestamp = data['sentTimestamp'].toDate();
      final sentOn =
          formatDate(sentTimestamp) + ' ' + formatTime(sentTimestamp);
      final senderUsername =
          await _getSenderUserame(data['senderId'], userChat);
      final photoStr = data['photoUrl'] == null ? '' : 'photo';
      final text = data['text'];
      chatHistory += '$sentOn $senderUsername: $photoStr $text\n';
    }
    return chatHistory;
  }

  Future<String> _getSenderUserame(String senderId, UserChat userChat) async {
    if (senderId == _auth.currentUser.id) return _auth.currentUser.username;
    if (userChat is UserPrivateChat) {
      return userChat.otherParticipant.user.username;
    }
    if (userChat is UserGroupChat) {
      final user = await _userDb.getUser(senderId);
      return user.username;
    }
    throw 'invalid chat type: ${userChat.runtimeType}';
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

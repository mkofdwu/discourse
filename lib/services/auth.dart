import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_settings.dart';
import 'package:discourse/services/user_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

abstract class BaseAuthService {
  bool get isSignedIn;
  DiscourseUser get currentUser;
  bool get emailVerified;
  Future<void> refreshCurrentUser();
  Future<Map<String, String>> signIn({
    required String email,
    required String password,
  });
  Future<Map<String, String>> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  });
  Future<void> updateEmail(String newEmail);
  Future<void> verifyEmail();
  Future<Map<String, String>> changePassword(
      String oldPassword, String newPassword);
  Future<void> signOut();
}

class AuthService extends GetxService implements BaseAuthService {
  final _fbAuth = FirebaseAuth.instance;
  final _userDb = Get.find<UserDbService>();

  DiscourseUser? _currentUser;

  @override
  bool get isSignedIn => _currentUser != null;

  @override
  DiscourseUser get currentUser => _currentUser!;

  String get id => _currentUser!.id;

  @override
  bool get emailVerified => _fbAuth.currentUser!.emailVerified;

  @override
  void onReady() {
    // mainly for email verification
    _fbAuth.authStateChanges().listen((user) {
      user?.reload();
    });
  }

  @override
  Future<void> refreshCurrentUser() async {
    if (_fbAuth.currentUser != null) {
      _currentUser = await _userDb.getUser(_fbAuth.currentUser!.uid);
    }
  }

  @override
  Future<Map<String, String>> signIn({
    required String email,
    required String password,
  }) async {
    final errors = {
      if (email.isEmpty) 'email': 'Please enter an email',
      if (password.isEmpty) 'password': 'Please enter a password'
    };
    if (errors.isNotEmpty) return errors;
    try {
      await _fbAuth.signInWithEmailAndPassword(
          email: email, password: password);
      await refreshCurrentUser();
      return {};
    } on FirebaseAuthException {
      return {'password': 'Invalid email or password'};
    }
  }

  @override
  Future<Map<String, String>> signUp({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final errors = {
      if (email.isEmpty) 'email': 'Please enter an email',
      if (username.isEmpty) 'username': 'Please enter an username',
      if (password.isEmpty) 'password': 'Please enter a password',
      if (confirmPassword != password)
        'confirmPassword': 'The passwords entered do not match',
    };
    if (errors.isNotEmpty) return errors;
    if (await _userDb.getUserByUsername(username) != null) {
      return {'username': 'This username is already taken'};
    }
    try {
      final credential = await _fbAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _userDb.setUserData(DiscourseUser(
        id: credential.user!.uid,
        email: email,
        username: username,
        settings: UserSettings(
          enableNotifications: true,
          showStoryTo: null,
          publicAccount: true, // for now to let everyone find each other
        ),
        relationships: {},
      ));
      await refreshCurrentUser();
      return {};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return {'email': 'This email is already taken'};
      }
      if (e.code == 'invalid-email') {
        return {
          'email': 'Your email cannot contain any spaces or invalid characters'
        };
      }
      if (e.code == 'weak-password') {
        return {'password': 'Your password must be at least 6 characters long'};
      }
      return {'email': e.message ?? ''};
    }
  }

  @override
  Future<void> signOut() async {
    await _fbAuth.signOut();
    _currentUser = null;
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    if (!isSignedIn) return;
    await _fbAuth.currentUser!.updateEmail(newEmail);
    _currentUser!.email = newEmail;
  }

  @override
  Future<void> verifyEmail() => _fbAuth.currentUser!.sendEmailVerification();

  @override
  Future<Map<String, String>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final fbUser = _fbAuth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: fbUser.email!,
      password: currentPassword,
    );
    try {
      await fbUser.reauthenticateWithCredential(credential);
      await fbUser.updatePassword(newPassword);
      return {};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return {'currentPassword': 'Invalid password'};
      }
      if (e.code == 'weak-password') {
        return {
          'newPassword': 'Your password must be at least 6 characters long',
        };
      }
      return {'currentPassword': e.message ?? ''};
    }
  }

  Future<void> deleteAccount() async {
    if (!isSignedIn) return;
    await _userDb.deleteUser(_currentUser!.id);
    await _fbAuth.currentUser!.delete();
    _currentUser = null;
  }
}

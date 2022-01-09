import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/user_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

abstract class BaseAuthService {
  bool get isSignedIn;
  DiscourseUser get currentUser;
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
      if (password.isEmpty) 'password': 'Please enter a password',
      if (confirmPassword != password)
        'confirmPassword': 'The passwords entered do not match',
    };
    if (errors.isNotEmpty) return errors;
    try {
      final credential = await _fbAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _userDb.setUserData(DiscourseUser(
        id: credential.user!.uid,
        email: email,
        username: username,
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
      return {'email': e.message ?? ''};
    }
  }

  @override
  Future<void> signOut() async {
    await _fbAuth.signOut();
    _currentUser = null;
  }

  Future<void> updateEmail(String newEmail) async {
    if (!isSignedIn) return;
    await _fbAuth.currentUser!.updateEmail(newEmail);
    _currentUser!.email = newEmail;
  }

  Future<void> deleteAccount() async {
    if (!isSignedIn) return;
    await _userDb.deleteUser(_currentUser!.id);
    await _fbAuth.currentUser!.delete();
    _currentUser = null;
  }
}

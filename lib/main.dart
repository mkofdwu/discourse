import 'package:discourse/constants/themes.dart';
import 'package:discourse/register_services.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/startup/startup_view.dart';
import 'package:discourse/widgets/app_state_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerServices();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(DiscourseApp());
}

class DiscourseApp extends StatelessWidget {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  DiscourseApp({Key? key}) : super(key: key);

  void _setOnline() {
    _userDb.setLastSeen(_auth.id, null);
  }

  void _setLastSeen() {
    _userDb.setLastSeen(_auth.id, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return AppStateHandler(
      onStart: _setOnline,
      onExit: _setLastSeen,
      child: GetMaterialApp(
        title: 'Discourse',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: kLightTheme,
        darkTheme: kDarkTheme,
        home: StartupView(),
        defaultTransition: Transition.rightToLeft,
        onReady: () {
          // hacky fix to call after all services have been initialized
          Future.delayed(Duration(seconds: 1), _setOnline);
        },
      ),
    );
  }
}

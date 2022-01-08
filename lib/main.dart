import 'package:discourse/constants/themes.dart';
import 'package:discourse/register_services.dart';
import 'package:discourse/views/startup/startup_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerServices();
  runApp(DiscourseApp());
}

class DiscourseApp extends StatelessWidget {
  const DiscourseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Discourse',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      home: StartupView(),
    );
  }
}

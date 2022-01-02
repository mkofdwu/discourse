import 'package:discourse/views/about/about_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/widgets/pressed_builder.dart';

class AppInfoLinks extends StatelessWidget {
  const AppInfoLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFineText('Version 0.1'),
        SizedBox(width: 18),
        PressedBuilder(
          onPressed: () => Get.to(AboutView()),
          builder: (pressed) => _buildFineText('About'),
        ),
        SizedBox(width: 18),
        PressedBuilder(
          onPressed: () => Get.to(LicensePage()),
          builder: (pressed) => _buildFineText('Licenses'),
        ),
      ],
    );
  }

  Widget _buildFineText(String text) => Text(
        text,
        style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 12),
      );
}

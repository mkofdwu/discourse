import 'package:carousel_slider/carousel_slider.dart';
import 'package:discourse/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'welcome_controller.dart';

final imageAssets = <String>[
  'assets/images/chats_page.png',
  'assets/images/user_profile_page.png',
  'assets/images/group_chat_page.png',
];

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WelcomeController>(
      init: WelcomeController(),
      builder: (controller) => Scaffold(
        body: Column(
          children: [
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  height: Get.height - 360,
                  viewportFraction: 0.7,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                ),
                items: imageAssets.map(_buildImage).toList(),
              ),
            ),
            Text(
              'discourse',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: Text(
                'A simple communication tool; an unconventional messaging application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xffffffff).withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 36, 40, 40),
              child: Row(
                children: [
                  Expanded(
                    child: MyButton(
                      text: 'Sign up',
                      fillWidth: true,
                      onPressed: controller.toSignUp,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      text: 'Sign in',
                      fillWidth: true,
                      isPrimary: false,
                      onPressed: controller.toSignIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String assetUrl) => Image.asset(assetUrl);
}

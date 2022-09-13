import 'package:carousel_slider/carousel_slider.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/views/home/home_controller.dart';
import 'package:discourse/views/settings/settings_view.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final items = <List<dynamic>>[
  [
    'assets/images/undraw_chatting.png',
    'Welcome!',
    'You don\'t have any chats yet. Find people to talk to in the explore tab',
    'Suggestions',
    () {
      Get.find<HomeController>().onSelectTab(1);
    }
  ],
  [
    'assets/images/undraw_personal_info.png',
    'Complete setup',
    'Finish setting up your profile by adding a profile pic or writing an about',
    'Continue',
    () {
      Get.find<HomeController>().onSelectTab(2);
    }
  ],
  [
    'assets/images/undraw_palette.png',
    'Choose a theme',
    'The app offers a selection of 6 different accent colors. There is currently no light theme.',
    'Choose one',
    () {
      Get.to(() => SettingsView());
    }
  ],
];

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: Get.height - 300,
            aspectRatio: 1,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() => _index = index);
            },
          ),
          items: items.map(_buildCard).toList(),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            SizedBox(width: 12),
            _buildDot(1),
            SizedBox(width: 12),
            _buildDot(2),
          ],
        )
      ],
    );
  }

  Widget _buildCard(dynamic item) => Container(
        decoration: BoxDecoration(
          color: Palette.black2,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Expanded(child: Image.asset(item[0])),
            Image.asset(item[0], height: 160),
            SizedBox(height: 32),
            Text(
              item[1],
              style: TextStyle(
                color: Get.theme.primaryColor.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Text(
              item[2],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Get.theme.primaryColor.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            _buildButton(item[3], item[4]),
            SizedBox(height: 40),
          ],
        ),
      );

  Widget _buildButton(String text, Function() onPressed) => OpacityFeedback(
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
          decoration: BoxDecoration(
            color: Palette.orange,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  Widget _buildDot(int i) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: i == _index
              ? Palette.orange
              : Get.theme.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

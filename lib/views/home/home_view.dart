import 'package:discourse/constants/palette.dart';
import 'package:discourse/views/chats/chats_view.dart';
import 'package:discourse/views/explore/explore_view.dart';
import 'package:discourse/views/my_profile/my_profile_view.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: _builder,
    );
  }

  Widget _builder(HomeController controller) => Scaffold(
        body: SafeArea(
          child: _buildBody(controller),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 14),
          color: Get.theme.primaryColorLight,
          child: Theme(
            data: Get.theme.copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: controller.currentTab,
              onTap: controller.onSelectTab,
              elevation: 0,
              selectedItemColor: Palette.orange,
              unselectedItemColor: Get.theme.primaryColor.withOpacity(0.6),
              selectedFontSize: 12,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
              enableFeedback: false,
              backgroundColor: Get.theme.primaryColorLight,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(FluentIcons.chat_multiple_24_regular),
                  ),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(FluentIcons.search_24_regular),
                  ),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(FluentIcons.person_24_regular),
                  ),
                  label: 'Profile',
                )
              ],
            ),
          ),
        ),
      );

  Widget _buildBody(HomeController controller) {
    switch (controller.currentTab) {
      case 0:
        return ChatsView();
      case 1:
        return ExploreView();
      case 2:
        return MyProfileView();
      default:
        return SizedBox.shrink();
    }
  }
}

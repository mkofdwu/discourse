import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/profile_photo.dart';
import 'package:get/get.dart';

import 'new_private_chat_controller.dart';

class NewPrivateChatView extends StatelessWidget {
  const NewPrivateChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewPrivateChatController>(builder: _builder);
  }

  Widget _builder(NewPrivateChatController controller) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 30, bottom: 40),
                child: _buildSearchTextField(controller),
              ),
              controller.searchController.text.isEmpty
                  ? Text(
                      "Enter someone's username\nto start searching",
                      textAlign: TextAlign.center,
                    )
                  : Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        itemCount: controller.searchResults.length,
                        separatorBuilder: (context, i) => SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final user = controller.searchResults[i];
                          return _buildUserTile(controller, user);
                        },
                      ),
                    )
            ],
          ),
        ),
      );

  Widget _buildSearchTextField(NewPrivateChatController controller) =>
      TextField(
        controller: controller.searchController,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: Palette.light0,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          hintText: 'Search for someone...',
          hintStyle: TextStyle(fontSize: 18, color: Palette.text1),
          suffixIcon: controller.searchController.text.isEmpty
              ? Icon(FluentIcons.search_20_regular, color: Palette.text1)
              : GestureDetector(
                  onTap: controller.clearSearch,
                  child: Icon(FluentIcons.dismiss_20_regular),
                ),
        ),
      );

  Widget _buildUserTile(
          NewPrivateChatController controller, DiscourseUser user) =>
      PressedBuilder(
        onPressed: () => controller.goToChatWith(user),
        builder: (pressed) => Transform.scale(
          scale: pressed ? 0.98 : 1,
          child: Opacity(
            opacity: pressed ? 0.8 : 1,
            child: Row(
              children: [
                ProfilePhoto(size: 44, url: user.photoUrl),
                SizedBox(width: 20),
                Text(
                  user.username,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
}

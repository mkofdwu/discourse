import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/profile_photo.dart';
import 'package:get/get.dart';

import 'add_participants_controller.dart';

class AddParticipantsView extends StatelessWidget {
  final List<String> excludeUserIds;

  const AddParticipantsView({Key? key, this.excludeUserIds = const <String>[]})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddParticipantsController>(
      builder: _builder,
    );
  }

  Widget _builder(AddParticipantsController controller) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 30, bottom: 40),
                child: _buildSearchTextField(controller),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (context, i) => SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final user = controller.searchResults[i];
                    return _buildUserTile(controller, user);
                  },
                ),
              ),
              if (controller.selectedUsers.isNotEmpty)
                _buildParticipantsCountAndNextButton(controller),
            ],
          ),
        ),
      );

  Widget _buildSearchTextField(AddParticipantsController controller) =>
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
          hintText: 'Add participants...',
          hintStyle: TextStyle(color: Palette.text1),
          suffixIcon: controller.searchController.text.isEmpty
              ? Icon(FluentIcons.search_20_regular, color: Palette.text1)
              : GestureDetector(
                  onTap: controller.clearSearch,
                  child: Icon(FluentIcons.dismiss_20_regular),
                ),
        ),
      );

  Widget _buildUserTile(
          AddParticipantsController controller, DiscourseUser user) =>
      PressedBuilder(
        onPressed: () => controller.toggleParticipant(user),
        builder: (pressed) => Transform.scale(
          scale: pressed ? 0.98 : 1,
          child: Opacity(
            opacity: pressed ? 0.8 : 1,
            child: Row(
              children: [
                _buildProfilePhoto(
                  user.photoUrl,
                  controller.selectedUsers.contains(user),
                ),
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

  Widget _buildProfilePhoto(String? photoUrl, bool isSelected) => Stack(
        children: [
          ProfilePhoto(size: 44, url: photoUrl),
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Icon(
                  FluentIcons.check_20_regular,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      );

  Widget _buildParticipantsCountAndNextButton(
          AddParticipantsController controller) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${controller.selectedUsers.length} participants selected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 20),
            PressedBuilder(
              onPressed: controller.submit,
              builder: (pressed) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Palette.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Icon(
                  FluentIcons.arrow_forward_20_regular,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      );
}

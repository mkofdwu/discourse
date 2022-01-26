import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/text_field.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'friend_list_controller.dart';

class FriendListView extends StatelessWidget {
  final List<DiscourseUser> selectedFriends;

  const FriendListView({
    Key? key,
    required this.selectedFriends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendListController>(
      init: FriendListController(selectedFriends),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: myAppBar(title: 'New friend list'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextField(
                controller: controller.nameController,
                label: 'List name',
                error: controller.nameError,
                onSubmit: () {},
              ),
              SizedBox(height: 44),
              Text(
                'Friends',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: selectedFriends
                    .map((user) => Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: PhotoOrIcon(
                            size: 60,
                            iconSize: 24,
                            photoUrl: user.photoUrl,
                            placeholderIcon: FluentIcons.person_24_regular,
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 40),
              Spacer(),
              Center(
                child: MyButton(
                  text: 'Submit',
                  onPressed: controller.submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/text_field.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'friend_list_controller.dart';

class FriendListView extends StatelessWidget {
  final String title;
  // passing entire FriendList object directly is not a good idea
  final String listName;
  final List<DiscourseUser> friends;
  final Map<IconData, Function()>? actions;

  const FriendListView({
    Key? key,
    required this.title,
    required this.listName,
    required this.friends,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendListController>(
      init: FriendListController(listName, friends),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: myAppBar(title: title, actions: actions),
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
              Row(
                children: [
                  Text(
                    'Friends',
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.4),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  OpacityFeedback(
                    onPressed: controller.addFriends,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
                      decoration: BoxDecoration(
                        color: Palette.black2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            FluentIcons.add_16_regular,
                            color: Palette.orange,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 12,
                              color: Palette.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  children: controller.friends
                      .map((user) => Stack(
                            children: [
                              Positioned(
                                left: 6,
                                top: 6,
                                right: 6,
                                bottom: 6,
                                child: PhotoOrIcon(
                                  radius: 32,
                                  iconSize: 24,
                                  photoUrl: user.photoUrl,
                                  placeholderIcon:
                                      FluentIcons.person_24_regular,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: OpacityFeedback(
                                  onPressed: () =>
                                      controller.removeFriend(user),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF505050),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            Get.theme.scaffoldBackgroundColor,
                                        width: 4,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        FluentIcons.dismiss_12_regular,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
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

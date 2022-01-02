import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/user.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/profile_photo.dart';
import 'package:get/get.dart';

import 'set_details_controller.dart';

class NewGroupSetDetailsView extends StatelessWidget {
  final List<DiscourseUser> users;

  const NewGroupSetDetailsView({Key? key, required this.users})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SetDetailsController>(builder: _builder);
  }

  Widget _builder(SetDetailsController controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text('new group')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoNameAndDescription(controller),
              SizedBox(height: 50),
              _buildParticipantsList(controller),
              Center(
                child: MyButton(
                  text: 'Create group',
                  onPressed: controller.createGroup,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPhotoNameAndDescription(SetDetailsController controller) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PressedBuilder(
            onPressed: controller.selectPhoto,
            builder: (pressed) => Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: pressed ? Palette.lightPressed : Palette.light0,
                borderRadius: BorderRadius.circular(60),
              ),
              clipBehavior: Clip.antiAlias,
              child: controller.hasPhoto
                  ? Image.file(
                      controller.photo!.file!,
                      fit: BoxFit.cover,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(FluentIcons.people_20_regular, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Add photo',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(width: 34),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.nameController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Name...',
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Description...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          )
        ],
      );

  Widget _buildParticipantsList(SetDetailsController controller) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PARTICIPANTS',
              style: TextStyle(
                color: Palette.text1,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (context, i) => SizedBox(width: 24),
                itemBuilder: (context, i) {
                  final user = users[i];
                  return _buildParticipantTile(user);
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildParticipantTile(DiscourseUser user) => Column(
        children: [
          ProfilePhoto(size: 80, url: user.photoUrl),
          SizedBox(height: 14),
          Text(
            user.username,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      );
}

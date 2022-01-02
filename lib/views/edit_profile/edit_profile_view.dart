import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/text_form_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import 'edit_profile_controller.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: _builder);
  }

  Widget _builder(EditProfileController controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('edit profile'),
          actions: [
            IconButton(
              icon: Icon(FluentIcons.settings_20_regular, size: 20),
              tooltip: 'Settings',
              onPressed: controller.goToSettings,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 100, bottom: 60),
          child: Column(
            children: [
              _buildPhoto(controller),
              SizedBox(height: 40),
              MyTextFormField(
                controller: controller.emailController,
                label: 'Email',
              ),
              Spacer(),
              MyButton(
                text: 'Update profile',
                onPressed: controller.updateProfile,
              ),
            ],
          ),
        ),
      );

  Widget _buildPhoto(EditProfileController controller) => PressedBuilder(
        onPressed: controller.selectPhoto,
        builder: (pressed) => Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: pressed ? Palette.lightPressed : Palette.light0,
            borderRadius: BorderRadius.circular(70),
            border: Border.all(width: 2, color: Colors.black),
            image: controller.photo != null
                ? DecorationImage(
                    image: controller.photo!.isLocal
                        ? FileImage(controller.photo!.file!) as ImageProvider
                        : CachedNetworkImageProvider(controller.photo!.url!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: controller.photo == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FluentIcons.person_20_regular,
                      color: Palette.text1,
                      size: 48,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add photo',
                      style: TextStyle(color: Palette.text1, fontSize: 12),
                    ),
                  ],
                )
              : null,
        ),
      );
}

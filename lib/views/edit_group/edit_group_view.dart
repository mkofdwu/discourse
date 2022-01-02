import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/text_form_field.dart';
import 'package:get/get.dart';

import 'edit_group_controller.dart';

class EditGroupView extends StatelessWidget {
  const EditGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditGroupController>(builder: _builder);
  }

  Widget _builder(EditGroupController controller) => Scaffold(
        appBar: AppBar(
          title: Text('edit group'),
        ),
        body: Builder(
          builder: (context) => SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  Scaffold.of(context).appBarMaxHeight!,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(60, 80, 60, 60),
                child: Column(
                  children: [
                    _buildPhoto(controller),
                    SizedBox(height: 40),
                    MyTextFormField(
                      controller: controller.nameController,
                      label: 'Name',
                    ),
                    SizedBox(height: 20),
                    MyTextFormField(
                      controller: controller.descriptionController,
                      label: 'Description',
                      fontSize: 20,
                      isMultiline: true,
                    ),
                    Spacer(),
                    MyButton(
                      text: 'Update',
                      onPressed: controller.updateDisplay,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildPhoto(EditGroupController controller) => PressedBuilder(
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
          clipBehavior: Clip.antiAlias,
          child: controller.photo == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.person_20_regular,
                        color: Palette.text1, size: 48),
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

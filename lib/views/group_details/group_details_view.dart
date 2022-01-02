import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/chat_participant.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/profile_photo.dart';
import 'package:get/get.dart';

import 'group_details_controller.dart';

class GroupDetailsView extends StatelessWidget {
  const GroupDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupDetailsController>(
      builder: _builder,
    );
  }

  Widget _builder(GroupDetailsController controller) => Scaffold(
        appBar: AppBar(
          title: Text('group details'),
          actions: [
            IconButton(
              icon: Icon(FluentIcons.edit_20_regular, size: 20),
              onPressed: controller.goToEditGroup,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          child: Column(
            children: [
              _buildPhotoNameAndDescription(controller),
              SizedBox(height: 50),
              _buildParticipantsHeader(controller),
              SizedBox(height: 30),
              _buildParticipantsList(controller),
            ],
          ),
        ),
      );

  Widget _buildPhotoNameAndDescription(GroupDetailsController controller) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhoto(controller),
          SizedBox(width: 34),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.groupData.name,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(controller.groupData.description),
              ],
            ),
          ),
        ],
      );

  Widget _buildPhoto(GroupDetailsController controller) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          border: Border.all(width: 2, color: Colors.black),
          image: controller.groupData.photoUrl != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                      controller.groupData.photoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: controller.groupData.photoUrl == null
            ? Icon(FluentIcons.people_32_regular, size: 40)
            : null,
      );

  Widget _buildParticipantsHeader(GroupDetailsController controller) => Row(
        children: [
          Text(
            'PARTICIPANTS',
            style: TextStyle(letterSpacing: 1.1),
          ),
          SizedBox(width: 10),
          Text(
            controller.groupData.participants.length.toString(),
            style: TextStyle(color: Palette.text1),
          ),
        ],
      );

  Widget _buildParticipantsList(GroupDetailsController controller) => Column(
        children: [_buildAddParticipantsTile(controller)] +
            controller.groupData.participants
                .map((participant) =>
                    _buildParticipantTile(controller, participant))
                .toList(),
      );

  Widget _buildAddParticipantsTile(GroupDetailsController controller) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: PressedBuilder(
          onPressed: controller.goToAddParticipants,
          builder: (pressed) => Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Palette.light0,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Icon(FluentIcons.add_20_regular,
                    color: Palette.text2, size: 20),
              ),
              SizedBox(width: 20),
              Text(
                'Add participants',
                style: TextStyle(
                  color: Palette.text2,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildParticipantTile(
    GroupDetailsController controller,
    Participant participant,
  ) {
    final actions = {
      participant.role == ParticipantRole.admin ? 'Remove admin' : 'Make admin':
          () => controller.toggleParticipantRole(participant),
      'Remove participant': () => controller.removeParticipant(participant)
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ProfilePhoto(size: 40, url: participant.user.photoUrl),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              participant.user.username,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          PopupMenuButton(
            icon: Icon(FluentIcons.more_vertical_20_regular),
            onSelected: (value) {
              actions[value]!();
            },
            itemBuilder: (context) {
              return actions
                  .map((title, method) => MapEntry(
                        title,
                        PopupMenuItem(value: title, child: Text(title)),
                      ))
                  .values
                  .toList();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'group_details_controller.dart';

double lerp(double from, double to, double extent) {
  return from + extent * (to - from);
}

class GroupDetailsAppBar extends StatefulWidget {
  final UserGroupChat chat;

  const GroupDetailsAppBar({Key? key, required this.chat}) : super(key: key);

  @override
  State<GroupDetailsAppBar> createState() => _GroupDetailsAppBarState();
}

class _GroupDetailsAppBarState extends State<GroupDetailsAppBar> {
  final _descriptionTextKey = GlobalKey();

  final double _expandedHeight = 400 + 52;
  final double _collapsedHeight = 76 + 52;

  GroupDetailsController get controller => Get.find<GroupDetailsController>();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _expandedHeight,
      collapsedHeight: _collapsedHeight,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Get.theme.primaryColorLight,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final current =
              constraints.biggest.height - Get.mediaQuery.padding.top;
          final extent = (current - _collapsedHeight) /
              (_expandedHeight - _collapsedHeight);
          final descriptionTextHeight = (_descriptionTextKey.currentContext
                  ?.findRenderObject() as RenderBox?)
              ?.size
              .height;
          // hacky solution to get full control
          return Stack(
            children: [
              FlexibleSpaceBar(
                background: GestureDetector(
                  onTap: controller.viewGroupPhoto,
                  child: widget.chat.photoUrl != null
                      ? Hero(
                          tag: widget.chat.photoUrl!,
                          child: Image.network(
                            widget.chat.photoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          color: Palette.orange.withOpacity(0.6),
                          child: Icon(
                            FluentIcons.people_community_28_regular,
                            color: Colors.white.withOpacity(0.1),
                            size: 96,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    lerp(74, 40, extent),
                    36,
                    lerp(28, 40, extent),
                    lerp(18 + 52, 30 + 52, extent),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(lerp(0, 0.6, extent)),
                        Colors.black.withOpacity(0),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        // feels very dirty but it works
                        offset: Offset(
                          0,
                          lerp(
                            descriptionTextHeight == null
                                ? 6
                                : descriptionTextHeight + 26,
                            0,
                            extent,
                          ),
                        ),
                        child: Text(
                          widget.chat.title,
                          style: TextStyle(
                            fontSize: lerp(16, 24, extent),
                            fontWeight: extent < 0.1
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      if (widget.chat.groupData.description.isNotEmpty)
                        Opacity(
                          opacity: lerp(0, 1, extent),
                          child: Text(
                            widget.chat.groupData.description,
                            key: _descriptionTextKey,
                          ),
                        ),
                      if (widget.chat.groupData.description.isNotEmpty)
                        SizedBox(height: 20),
                      Text(
                        // TODO
                        'Created by you, 19/04/2021',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: lerp(12, 14, extent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // this needs to be on top so it can be clicked
              _buildButtons(extent),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildTabBar(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButtons(double extent) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: lerp(24, 40, extent),
            top: lerp(20, 36, extent),
            right: lerp(24, 40, extent),
          ),
          child: Row(
            children: [
              extent < 0.1
                  ? MyIconButton(
                      FluentIcons.chevron_left_24_regular,
                      onPressed: Get.back,
                    )
                  : _buildBackButton(extent),
              Spacer(),
              if (controller.hasAdminPrivileges)
                _buildButton(
                  extent,
                  FluentIcons.edit_20_regular,
                  controller.editNameAndDescription,
                ),
              SizedBox(width: 12),
              _buildButton(
                extent,
                FluentIcons.more_vertical_20_regular,
                controller.showGroupOptions,
              ),
            ],
          ),
        ),
      );

  Widget _buildBackButton(double extent) => PressedBuilder(
        onPressed: Get.back,
        builder: (pressed) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(pressed ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                FluentIcons.chevron_left_20_regular,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'BACK',
                style: TextStyle(
                  color: Colors.white.withOpacity(lerp(0, 1, extent)),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildButton(
          double extent, IconData iconData, VoidCallback onPressed) =>
      extent < 0.1
          ? MyIconButton(iconData, onPressed: onPressed)
          : PressedBuilder(
              onPressed: onPressed,
              builder: (pressed) => AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(pressed ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, size: 20),
              ),
            );

  Widget _buildTabBar() => Container(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Palette.black3,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: TabBar(
            isScrollable: true, // uneven tab sizes
            labelColor: Palette.orange,
            unselectedLabelColor: Colors.white.withOpacity(0.4),
            indicatorColor: Palette.orange,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 4),
            tabs: const [
              Tab(text: 'Members'),
              Tab(text: 'Photos & videos'),
              Tab(text: 'Links'),
              Tab(text: 'Files'),
            ],
          ),
        ),
      );
}

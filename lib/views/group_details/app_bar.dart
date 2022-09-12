import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
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
              _buildPhoto(),
              _buildDetailsText(extent, descriptionTextHeight),
              // this needs to be on top so it can be clicked
              _buildTopButtons(extent),
              _buildTabBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoto() {
    return FlexibleSpaceBar(
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
    );
  }

  Positioned _buildDetailsText(double extent, double? descriptionTextHeight) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
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
                Colors.black.withOpacity(lerp(0, 0.8, extent)),
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
                    fontWeight:
                        extent < 0.1 ? FontWeight.w500 : FontWeight.w700,
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
    );
  }

  Widget _buildTopButtons(double extent) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.chat.photoUrl == null
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(lerp(0, 0.4, extent)),
                  Colors.black.withOpacity(0),
                ],
              ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: lerp(28, 40, extent),
            top: lerp(20, 32, extent),
            right: lerp(20, 32, extent),
            bottom: 36,
          ),
          child: Row(
            children: [
              OpacityFeedback(
                onPressed: Get.back,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.chevron_left_24_regular),
                    SizedBox(width: 8),
                    Text(
                      'BACK',
                      style: TextStyle(
                        color: Colors.white.withOpacity(lerp(0, 1, extent)),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.4,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              if (controller.hasAdminPrivileges)
                MyIconButton(
                  FluentIcons.edit_24_regular,
                  size: 22,
                  onPressed: controller.editNameAndDescription,
                ),
              SizedBox(width: lerp(8, 12, extent)),
              MyIconButton(
                FluentIcons.more_vertical_24_regular,
                onPressed: controller.showGroupOptions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
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
      ),
    );
  }
}

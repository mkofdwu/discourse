import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/user_chat.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/profile_photo.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: _builder);
  }

  Widget _builder(HomeController controller) => Scaffold(
        appBar: AppBar(
          title: Text('chats'),
          actions: <Widget>[
            IconButton(
              icon: Icon(FluentIcons.add_20_regular, size: 20),
              onPressed: controller.newChat,
            ),
            IconButton(
              icon: Icon(FluentIcons.person_20_regular, size: 20),
              onPressed: controller.goToEditProfile,
            ),
          ],
        ),
        body: controller.loading
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                itemCount: controller.chats.length,
                itemBuilder: (context, i) {
                  final userChat = controller.chats[i];
                  return _buildChatTile(controller, userChat);
                },
                separatorBuilder: (context, i) => SizedBox(height: 24),
              ),
      );

  Widget _buildChatTile(HomeController controller, UserChat userChat) {
    return PressedBuilder(
      onPressed: () => controller.goToChat(userChat),
      builder: (pressed) => Transform.scale(
        scale: pressed ? 0.98 : 1,
        child: Opacity(
          opacity: pressed ? 0.8 : 1,
          child: Row(
            children: [
              ProfilePhoto(
                size: 60,
                url: userChat is UserPrivateChat
                    ? userChat.otherParticipant.user.photoUrl
                    : userChat.groupData.photoUrl,
                placeholderIcon: userChat is UserPrivateChat
                    ? FluentIcons.person_20_regular
                    : FluentIcons.people_20_regular,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userChat.title, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    if (userChat.data.lastMessageText != null)
                      Text(
                        userChat.data.lastMessageText!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Palette.text1),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

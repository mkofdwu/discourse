import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class ViewedByView extends StatelessWidget {
  final List<DiscourseUser> viewedBy;

  const ViewedByView({Key? key, required this.viewedBy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(title: 'Viewed by'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
        child: Column(
          children: viewedBy
              .map((user) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: MyListTile(
                      title: user.username,
                      photoUrl: user.photoUrl,
                      subtitle: null,
                      iconData: FluentIcons.person_16_regular,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

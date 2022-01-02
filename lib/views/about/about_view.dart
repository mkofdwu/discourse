import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('about simple chat'),
        actions: [
          IconButton(
            icon: Icon(FluentIcons.dismiss_20_regular, size: 20),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Simple chat is a simple chat application created with flutter. It was mainly created to pratice concepts of clean architecture with the stacked framework in flutter.'),
            SizedBox(height: 48),
            Container(
              width: double.infinity,
              height: 2,
              color: Colors.black,
            ),
            SizedBox(height: 14),
            Text(
              'Developed by',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/dev.png'),
                ),
                SizedBox(width: 12),
                Text('Jane Cooper',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

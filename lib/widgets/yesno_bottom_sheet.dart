import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/widgets/button.dart';

class YesNoBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;

  const YesNoBottomSheet({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 26),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(subtitle),
          SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: MyButton(
                  text: 'Confirm',
                  fillWidth: true,
                  onPressed: () => Get.back(result: true),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: MyButton(
                  text: 'Cancel',
                  isPrimary: false,
                  fillWidth: true,
                  onPressed: () => Get.back(result: false),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

import 'package:discourse/widgets/pressed_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoiceBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> choices;

  const ChoiceBottomSheet({
    Key? key,
    required this.title,
    this.subtitle,
    required this.choices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) SizedBox(height: 12),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style:
                      TextStyle(color: Get.theme.primaryColor.withOpacity(0.6)),
                ),
              SizedBox(height: 24),
              ...choices
                  .map((choice) => PressedBuilder(
                        builder: (pressed) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(choice, style: TextStyle(fontSize: 16)),
                        ),
                        onPressed: () => Get.back(result: choice),
                      ))
                  .toList(),
              PressedBuilder(
                builder: (pressed) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                onPressed: () => Get.back(result: null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:discourse/widgets/opacity_feedback.dart';
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
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 26, 30, 26),
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
                  style: TextStyle(
                    color: Get.theme.primaryColor.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              SizedBox(height: 24),
              ...choices
                  .map((choice) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OpacityFeedback(
                          child: Text(
                            choice,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () => Get.back(result: choice),
                        ),
                      ))
                  .toList(),
              OpacityFeedback(
                child: Text('Cancel', style: TextStyle(fontSize: 16)),
                onPressed: () => Get.back(result: null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

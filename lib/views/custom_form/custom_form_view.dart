import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_form.dart';
import 'custom_form_controller.dart';

class CustomFormView extends StatelessWidget {
  final CustomForm form;

  const CustomFormView({Key? key, required this.form}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomFormController>(
      global: false,
      init: CustomFormController(form),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: myAppBar(title: form.title),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...form.fields
                  .map((field) => field.widgetBuilder(
                        controller.errors[field.name],
                        controller.createValueChangedHandler(field.name),
                      ))
                  .map(
                    (widget) => Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: widget,
                    ),
                  )
                  .toList(),
              Spacer(),
              MyButton(text: 'Submit', onPressed: controller.submit),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
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
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (form.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 30),
                  child: Text(
                    form.description!,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                )
              else
                SizedBox(height: 40),
              ...form.fields
                  .map((field) => field.widgetBuilder(
                        controller.errors[field.name],
                        controller.getValueController(
                          field.name,
                          field.defaultValue,
                        ),
                      ))
                  .map(
                    (widget) => Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: widget,
                    ),
                  )
                  .toList(),
              Spacer(),
              MyButton(
                text: 'Submit',
                isLoading: controller.isLoading,
                onPressed: controller.submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

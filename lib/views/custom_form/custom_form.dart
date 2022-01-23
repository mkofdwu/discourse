import 'package:discourse/views/custom_form/custom_form_controller.dart';
import 'package:discourse/widgets/text_field.dart';
import 'package:flutter/material.dart';

class Field {
  final String name;
  final dynamic defaultValue;
  final Widget Function(String? error, ValueController valueController)
      widgetBuilder;

  Field(this.name, this.defaultValue, this.widgetBuilder);
}

Widget Function(String? error, ValueController valueController)
    textFieldBuilder({
  required String label,
  bool obscureText = false,
  bool isMultiline = false,
  bool isLast = false,
}) {
  return (error, valueController) {
    return MyTextField(
      controller: TextEditingController(text: valueController.value),
      label: label,
      obscureText: obscureText,
      error: error,
      onChanged: (newValue) {
        valueController.value = newValue;
      },
      numLines: isMultiline ? 5 : 1,
      // this is to set textinputaction correctly:
      // to move focus to next field or to close the keyboard
      onSubmit: isLast ? () {} : null,
    );
  };
}

class CustomForm {
  final String title;
  final String? description;
  final List<Field> fields;
  final void Function(
    Map<String, dynamic> inputs,
    Function(Map<String, String>) setErrors,
  ) onSubmit;

  CustomForm({
    required this.title,
    this.description,
    required this.fields,
    required this.onSubmit,
  });
}

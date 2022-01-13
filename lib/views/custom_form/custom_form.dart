import 'package:discourse/widgets/text_field.dart';
import 'package:flutter/material.dart';

class Field {
  final String name;
  final Widget Function(String? error, Function(dynamic) onChanged)
      widgetBuilder;

  Field(this.name, this.widgetBuilder);
}

Widget Function(String? error, Function(dynamic) onChanged) textFieldBuilder({
  required String label,
  bool obscureText = false,
  String? defaultValue,
}) {
  return (error, onChanged) => MyTextField(
        controller: TextEditingController(text: defaultValue),
        label: label,
        obscureText: obscureText,
        error: error,
        onChanged: onChanged,
      );
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

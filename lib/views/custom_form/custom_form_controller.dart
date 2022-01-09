import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_form.dart';

class CustomFormController extends GetxController {
  final Map<String, dynamic> _values = {};
  Map<String, String> errors = {};
  bool isLoading = false;

  final CustomForm _form;

  CustomFormController(this._form);

  Function(dynamic) createValueChangedHandler(String field) {
    return (newValue) {
      _values[field] = newValue;
    };
  }

  void submit() {
    isLoading = true;
    update();
    _form.onSubmit(_values, (inputErrors) {
      errors = inputErrors;
      isLoading = false;
      update();
    });
  }
}

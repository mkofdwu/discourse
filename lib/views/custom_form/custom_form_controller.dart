import 'package:get/get.dart';

import 'custom_form.dart';

class ValueController {
  dynamic value;

  ValueController(this.value);
}

class CustomFormController extends GetxController {
  // final Map<String, dynamic> _values = {};
  // final Map<String, Function(dynamic)> valueChangedHandlers = {};
  final Map<String, ValueController> _controllers = {};
  Map<String, String> errors = {};
  bool isLoading = false;

  final CustomForm _form;

  CustomFormController(this._form);

  ValueController getValueController(String fieldName, dynamic defaultValue) {
    if (!_controllers.containsKey(fieldName)) {
      _controllers[fieldName] = ValueController(defaultValue);
    }
    return _controllers[fieldName]!;
  }

  void submit() {
    isLoading = true;
    update();
    final values = _controllers.map((name, c) => MapEntry(name, c.value));
    _form.onSubmit(values, (inputErrors) {
      errors = inputErrors;
      isLoading = false;
      update();
    });
  }
}

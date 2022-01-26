import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:flutter/material.dart';

class RadioGroup<S> extends StatefulWidget {
  final Map<S, String> options;
  final S defaultValue;
  final Function onSelect;
  final Function onEdit;

  const RadioGroup({
    Key? key,
    required this.options,
    required this.defaultValue,
    required this.onSelect,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<RadioGroup> createState() => _RadioGroupState();
}

class _RadioGroupState<S> extends State<RadioGroup<S>> {
  S? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options
          .map((value, name) => MapEntry(
              value,
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _value = value);
                        widget.onSelect(value);
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: value == _value ? Colors.white : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    OpacityFeedback(
                      child: Text(name),
                      onPressed: () => widget.onEdit(value),
                    ),
                  ],
                ),
              )))
          .values
          .toList(),
    );
  }
}

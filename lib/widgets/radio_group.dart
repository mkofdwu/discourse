import 'package:flutter/material.dart';

class RadioGroup extends StatefulWidget {
  final List<String> options;
  final String defaultOption;
  final Function(String) onSelect;

  const RadioGroup({
    Key? key,
    required this.options,
    required this.defaultOption,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<RadioGroup> createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.defaultOption;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options
          .map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedOption = option);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              option == _selectedOption ? Colors.white : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(option),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

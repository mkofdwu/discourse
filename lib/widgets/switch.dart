import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySwitch extends StatefulWidget {
  final bool defaultValue;
  final Function(bool) onChanged;

  const MySwitch({
    Key? key,
    required this.defaultValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<MySwitch> createState() => _MySwitchState();
}

class _MySwitchState extends State<MySwitch> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _value = !_value);
        widget.onChanged(_value);
      },
      child: Stack(
        children: [
          SizedBox(width: 38, height: 20),
          Positioned(
            left: 2,
            top: 2,
            right: 2,
            bottom: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Get.theme.primaryColor.withOpacity(0.2)),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: _value ? 18 : 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

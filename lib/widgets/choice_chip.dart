import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';

class MyChoiceChip extends StatefulWidget {
  final String text;
  final Function(bool) onChanged;

  const MyChoiceChip({Key? key, required this.text, required this.onChanged})
      : super(key: key);

  @override
  MyChoiceChipState createState() => MyChoiceChipState();
}

class MyChoiceChipState extends State<MyChoiceChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _selected = !_selected);
      },
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Palette.black3,
          borderRadius: BorderRadius.circular(15),
          border: _selected ? Border.all(color: Colors.white) : null,
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: _selected ? Colors.white : Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        spinnerMode: true,
        size: 40,
        customColors: CustomSliderColors(
          progressBarColor: Palette.orange,
          trackColor: Colors.transparent,
          dotColor: Colors.transparent,
          hideShadow: true,
        ),
        customWidths: CustomSliderWidths(
          progressBarWidth: 4,
        ),
      ),
    );
  }
}

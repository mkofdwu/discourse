import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';

// no idea how material design guidelines work, for now:
// primaryColor: color for text
// primaryColorLight: subtler color on background
// colorScheme.primary: accent color (orange)

final kLightTheme = ThemeData(
  fontFamily: 'Avenir',
  scaffoldBackgroundColor: Color(0xfff8f8f8),
  primaryColor: Colors.black,
  // primaryColorLight: Colors.black,
  appBarTheme: AppBarTheme(elevation: 0),
  colorScheme: ColorScheme.light(primary: Palette.orange),
);

final kDarkTheme = ThemeData(
  fontFamily: 'Avenir',
  scaffoldBackgroundColor: Palette.black1,
  primaryColor: Colors.white,
  primaryColorLight: Palette.black2,
  textTheme: TextTheme(
    bodyText1: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.orange,
    onPrimary: Colors.black,
  ),
);

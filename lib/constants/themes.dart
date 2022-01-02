import 'package:discourse/constants/palette.dart';
import 'package:flutter/material.dart';

final kLightTheme = ThemeData(
  backgroundColor: Color(0xfff8f8f8),
  scaffoldBackgroundColor: Color(0xfff8f8f8),
  appBarTheme: AppBarTheme(elevation: 0),
  colorScheme: ColorScheme.light(
    primary: Colors.white,
    secondary: Palette.accent,
    error: Palette.red,
  ),
);

final kDarkTheme = kLightTheme.copyWith(
  backgroundColor: Color(0xff1e1e1e),
  scaffoldBackgroundColor: Color(0xff1e1e1e),
  colorScheme: ColorScheme.dark(
    primary: Colors.black,
    secondary: Palette.accentDark,
    error: Palette.red,
  ),
);

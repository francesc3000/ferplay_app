import 'package:flutter/material.dart';

final ThemeData _androidTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blueGrey,
  accentColor: Colors.grey,
  buttonColor: Colors.grey,
);

final ThemeData _iOSTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.grey,
  accentColor: Colors.blue,
  buttonColor: Colors.blue,
);

ThemeData getAdaptiveThemeData(context) {
  return Theme.of(context).platform == TargetPlatform.android ? _androidTheme : _iOSTheme;
}

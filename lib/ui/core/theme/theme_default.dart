import 'package:flutter/material.dart';

class ThemeDefault {
  static const Map<String, Color> _colorMap = {
    "primary": Colors.deepPurple,
    "secondary": Colors.white,
  };

  static ThemeData defaultTheme() => ThemeData(
    primaryColor: Colors.deepPurple,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
    ),
    brightness:  Brightness.dark,
  );

  static ThemeData oldTheme() => ThemeData(
    primaryColor: Colors.deepPurple,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
    ),
  );
}
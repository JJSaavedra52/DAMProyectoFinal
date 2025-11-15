import 'package:flutter/material.dart';

class ThemeDefault {
  static ThemeData defaultTheme() => ThemeData(
    //primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
    ),
  );

  static ThemeData oldTheme() => ThemeData(
    primaryColor: Colors.deepPurple,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
    ),
  );
}
//mateapp

//Installar provider
//flutter pub add provider
//This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):
//dependencies:
//  provider: ^6.1.5+1

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/pages/home_page.dart';
import 'package:qr_reader/pages/mapa_page.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/providers/ui_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) =>  UiProvider()),
        ChangeNotifierProvider(create: (_) =>  ScanListProvider()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QR Reader',

        initialRoute: 'home',

        routes: {'home': (_) => HomePage(), 
                 'mapa': (_) => MapaPage()},
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ),
    );

  }
}

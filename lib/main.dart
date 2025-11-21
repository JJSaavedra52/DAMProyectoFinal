import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/app_export.dart';
import 'package:qr_reader/ui/user/user_exports.dart';
import 'package:qr_reader/ui/scan_history/scan_history_exports.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => ScanListProvider()),
        ChangeNotifierProvider(create: (_) => ApiProvider()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QR Reader',
        initialRoute: 'user', // start app on the login/register screen
        routes: {
          'home': (_) => HomePage(),
          //'mapa': (_) => MapaPage(),
          'mapa_punto_a_punto': (_) => MapPuntoAPunto(),
          'user': (_) => const UserPage(),
          'history': (_) => const ScanHistoryPage(),
        },
        theme: ThemeDefault.defaultTheme(),
      ),
    );
  }
}

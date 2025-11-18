import 'package:flutter/material.dart';
import 'package:qr_reader/app_export.dart';


class DireccionesPage extends StatelessWidget {
  const DireccionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanTiles(tipo: 'http');
  }
}

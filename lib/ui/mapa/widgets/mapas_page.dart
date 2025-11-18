import 'package:flutter/material.dart';
import 'package:qr_reader/app_export.dart';


class MapasPage extends StatelessWidget {
  const MapasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanTiles(tipo: 'geo');
  }
}
/*
import 'package:flutter/material.dart';

class MapasPage extends StatelessWidget {
   
  const MapasPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Mapas Page'),

    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:qr_reader/ui/core/ui/scan_tiles.dart';


class MapasPage extends StatelessWidget {
  const MapasPage({super.key});


  @override
  Widget build(BuildContext context) {

    return ScanTiles(tipo: 'geo');
  
  }
}
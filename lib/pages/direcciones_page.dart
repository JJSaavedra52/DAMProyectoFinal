/*
import 'package:flutter/material.dart';

class DireccionesPage extends StatelessWidget {
   
  const DireccionesPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Direcciones Page'),

    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:qr_reader/widgets/scan_tiles.dart';


class DireccionesPage extends StatelessWidget {
  const DireccionesPage({super.key});


  @override
  Widget build(BuildContext context) {
    
    return ScanTiles(tipo: 'http');
  }
}

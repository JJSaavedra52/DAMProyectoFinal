/*
import 'package:flutter/material.dart';

class OtraPage extends StatelessWidget {
   
  const OtraPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
         child: Text('Otra Page'),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:qr_reader/widgets/scan_tiles.dart';


class OtraPage extends StatelessWidget {
  const OtraPage({super.key});

  @override
  Widget build(BuildContext context) {

    return ScanTiles(tipo: 'otro');
  
  }


}
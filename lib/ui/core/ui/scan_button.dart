import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/app_export.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      child: Icon(Icons.filter_center_focus),

      onPressed: () async {

        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QRScannerPage()),
        );

        if (result != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Scanned value: $result')));
        }

        String barcodeScanRes = result;

      
        /*
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>  const QRViewExample()),
        );
        

        if (result != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Scanned value: $result')));
        }
        */




        //String barcodeScanRes =
        /*
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const QRViewExample()));
        */

        //print(barcodeScanRes);

        /*
        String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#3D8BEF',
          'Cancelar',
          false,
          ScanMode.QR,
        );
        */

        //final barcodeScanRes = 'https://fernando-herrera.com';
        //final barcodeScanRes = 'geo:45.287135,-75.920226';


        if (barcodeScanRes == '-1') {
          return;
        }

        final scanListProvider = Provider.of<ScanListProvider>(
          context,
          listen: false,
        );

        final nuevoScan = await scanListProvider.nuevoScan(barcodeScanRes);

        launchURL(context, nuevoScan);
        
      },
    );
  }
}



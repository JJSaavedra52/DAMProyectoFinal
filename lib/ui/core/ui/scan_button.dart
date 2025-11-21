import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/app_export.dart';
import 'package:qr_reader/ui/qr_scanner/widgets/qr_scanner_page.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      child: const Icon(Icons.filter_center_focus),
      onPressed: () async {
        // Open scanner and wait result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QRScannerPage()),
        );

        if (result == null) return;

        // Determine a usable scanned string (prefer .valor if present)
        String scannedString;
        if (result is String) {
          scannedString = result.trim();
        } else {
          try {
            final valor = (result as dynamic).valor;
            scannedString = (valor is String)
                ? valor.trim()
                : result.toString();
          } catch (_) {
            scannedString = result.toString();
          }
        }

        // If it's the special cancel code from some scanners
        if (scannedString == '-1') return;

        // Show a short feedback (readable)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned value: $scannedString')),
        );

        // Save the scan via provider (nuevoScan expects the raw string)
        final scanListProvider = Provider.of<ScanListProvider>(
          context,
          listen: false,
        );

        final nuevoScan = await scanListProvider.nuevoScan(scannedString);

        // Navigate to mapa with the created ScanModel so MapaPage shows it
        try {
          Navigator.pushNamed(context, 'mapa', arguments: nuevoScan);
        } catch (_) {
          // fallback: if mapa expects a string, pass the raw string
          Navigator.pushNamed(context, 'mapa', arguments: scannedString);
        }
      },
    );
  }
}

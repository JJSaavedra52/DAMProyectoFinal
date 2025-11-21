import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_reader/domain/providers/api_provider.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  // Fix hot reload for camera on Android/iOS
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blueAccent,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scannedData != null ? 'Scanned: $scannedData' : 'Scan a code',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      _handleScan(scanData);
    });
  }

  Future<void> _handleScan(Barcode scanData) async {
    final code = scanData.code;
    if (code == null) return;

    setState(() => scannedData = code);

    // stop scanning after first result
    await controller?.pauseCamera();

    try {
      // Ensure token loaded if present
      await ApiProvider().ensureAuth();

      if (ApiProvider().isAuthenticated) {
        // create scan on backend
        final created = await ApiProvider().createScan(valor: code);
        if (mounted) Navigator.pop(context, created);
      } else {
        // not authenticated: return raw scanned string
        if (mounted) Navigator.pop(context, code);
      }
    } catch (e) {
      // minimal feedback and return scanned text so the calling screen can handle it
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('API error: ${e.toString()}')));
        Navigator.pop(context, code);
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

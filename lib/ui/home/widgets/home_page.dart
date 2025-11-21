import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/ui/qr_scanner/widgets/qr_scanner_page.dart';
import 'package:qr_reader/app_export.dart'; // for ScanModel if present

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Historial'),
        centerTitle: true,

        backgroundColor: Colors.deepPurple,

        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () {
              Provider.of<ScanListProvider>(
                context,
                listen: false,
              ).borrarTodos();
            },
          ),
        ],
      ),

      //body: Center(child: Text('Home Page')),

      //body: MapasPage(),
      //body: DireccionesPage(),
      body: _HomePageBody(),

      bottomNavigationBar: CustomNavigatorBar(),

      floatingActionButton: ScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _HomePageBody extends StatelessWidget {
  const _HomePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    /*
    return Container(
      child: Text('Algo'),
    );
    */

    // Obtener el selected menu opt
    final uiProvider = Provider.of<UiProvider>(context);

    // Cambiar para mostrar la pagina respectiva
    final currentIndex = uiProvider.selectedMenuOpt;

    //final currentIndex = 1;

    //final currentIndex = uiProvider.selectedMenuOpt;

    // Usar el ScanListProvider
    final scanListProvider = Provider.of<ScanListProvider>(
      context,
      listen: false,
    );

    switch (currentIndex) {
      case 0:
        scanListProvider.cargarScanPorTipo('geo');
        return MapasPage();

      case 1:
        scanListProvider.cargarScanPorTipo('http');
        return DireccionesPage();

      case 2:
        scanListProvider.cargarScanPorTipo('otro');
        return OtraPage();

      case 3:
        scanListProvider.cargarScanPorTipo('test');
        return MapPuntoAPunto();

      default:
        return MapasPage();
    }
  }
}

// Replace any existing direct scanner launcher like:
// Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerPage()));
// with:
Future<void> openScannerAndHandleResult(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const QRScannerPage()),
  );
  if (result == null) return;

  String? geoValue;

  // handle common possibilities: ScanModel, Scan, or raw String
  if (result is ScanModel) {
    final valor = result.valor ?? '';
    final tipo = (result.tipo ?? '').toLowerCase();
    if (tipo == 'geo' && valor.isNotEmpty)
      geoValue = valor;
    else if (valor.toLowerCase().startsWith('geo'))
      geoValue = valor;
  } else if (result is String) {
    final s = result.trim();
    if (s.toLowerCase().startsWith('geo')) geoValue = s;
  } else {
    // dynamic fallback for other scan objects
    try {
      final valor = (result as dynamic).valor;
      if (valor is String && valor.toLowerCase().startsWith('geo'))
        geoValue = valor;
    } catch (_) {}
  }

  if (geoValue != null) {
    Navigator.pushNamed(context, 'mapa', arguments: geoValue);
    return;
  }

  // fallback: show readable summary rather than "Instance of ..."
  final summary = (result is String)
      ? result
      : (result is ScanModel
            ? (result.valor ?? result.toString())
            : result.toString());
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Scanned value: $summary')));
}

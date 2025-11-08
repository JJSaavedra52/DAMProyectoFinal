import 'package:flutter/material.dart';
//import 'package:qr_reader/providers/db_provider.dart';
import 'package:qr_reader/providers/db_provider1.dart';

class ScanListProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  String tipoSeleccionado = 'http';

  Future<ScanModel> nuevoScan(String valor) async {

    final nuevoScan = ScanModel(valor: valor);

    final id = await DBProvider1.db.nuevoScan(nuevoScan);
    // Asignar el ID de la base de datos al modelo
    nuevoScan.id = id;

    if (tipoSeleccionado == nuevoScan.tipo) {
      scans.add(nuevoScan);
      notifyListeners();
    }

    return nuevoScan;
  }

  Future<void> cargarScans() async {
    final scans = await DBProvider1.db.getTodosLosScans();
    this.scans = [...scans];
    notifyListeners();
  }

  Future<void> cargarScanPorTipo(String tipo) async {
    final scans = await DBProvider1.db.getScansPorTipo(tipo);
    this.scans = [...scans];
    tipoSeleccionado = tipo;
    notifyListeners();
  }

  Future<void> borrarTodos() async {
    await DBProvider1.db.deleteAllScans();
    scans = [];
    notifyListeners();
  }

  Future<void> borrarScanPorId(int id) async {
    await DBProvider1.db.deleteScan(id);
  }
}

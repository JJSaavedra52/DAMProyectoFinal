import 'package:flutter/material.dart';
import 'package:qr_reader/app_export.dart';

class ScanListProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  String tipoSeleccionado = 'http';

  Future<ScanModel> nuevoScan(String valor) async {
    AppLocation location = await geoLocalizar();
    final nuevoScan = ScanModel(valor: valor, location: location.toString());

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

  static Future<AppLocation> geoLocalizar() async {
    final locationService = LocationService();

    // Obtener ubicación actual
    final position = await locationService.getCurrentLocation();

    if (position != null) {
      final location = AppLocation.fromPosition(position);
      debugPrint('Ubicación obtenida: ${location.toString()}');

      _useLocationForSomething(location);
      return location;
    } else {
      debugPrint('No se pudo obtener la ubicación');
    }
    throw "Ha ocurrido un error";
  }

  static void _useLocationForSomething(AppLocation location) {
    // Hacer algo con la ubicación
    debugPrint('Latitud: ${location.latitude}');
    debugPrint('Longitud: ${location.longitude}');
  }
}

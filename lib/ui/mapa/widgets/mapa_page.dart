import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_reader/app_export.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final Completer<GoogleMapController> _controller = Completer();
  MapType mapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    LatLng latLng;
    String title = 'Mapa';
    String tipo = 'geo';
    String valor = '';

    if (args is ScanModel) {
      // handle nullable fields in ScanModel safely
      tipo = args.tipo ?? 'geo';
      valor = args.valor ?? '';
      try {
        latLng = _getLatLngFromScan(args);
        title = 'Mapa - $tipo';
      } catch (e) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mapa')),
          body: const Center(
            child: Text('Scan inválido: coordenadas no disponibles'),
          ),
        );
      }
    } else if (args is String && args.trim().toLowerCase().startsWith('geo')) {
      final s = args.trim();
      // accept both "geo:lat,lng" and "geo: lat,lng"
      final coordPart = s.contains(':') ? s.split(':').sublist(1).join(':') : s;
      final parts = coordPart.split(',');
      if (parts.length < 2) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mapa')),
          body: const Center(child: Text('Formato geo inválido')),
        );
      }
      try {
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        latLng = LatLng(lat, lng);
        valor = 'geo:$lat,$lng';
        title = 'Mapa - geo';
        tipo = 'geo';
      } catch (e) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mapa')),
          body: const Center(child: Text('Formato geo inválido')),
        );
      }
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: const Center(child: Text('No se proporcionó scan válido')),
      );
    }

    final puntoInicial = CameraPosition(target: latLng, zoom: 17);
    final markerId = MarkerId(
      valor.isNotEmpty ? valor : '${latLng.latitude},${latLng.longitude}',
    );
    final markers = <Marker>{
      Marker(
        markerId: markerId,
        position: latLng,
        infoWindow: InfoWindow(title: valor, snippet: tipo),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(
              mapType == MapType.normal ? Icons.satellite_alt : Icons.map,
            ),
            onPressed: () => setState(() {
              mapType = mapType == MapType.normal
                  ? MapType.hybrid
                  : MapType.normal;
            }),
          ),
        ],
      ),
      body: GoogleMap(
        mapType: mapType,
        initialCameraPosition: puntoInicial,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () async {
          final controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(puntoInicial),
          );
        },
      ),
    );
  }

  LatLng _getLatLngFromScan(ScanModel scan) {
    // prefer ScanModel helper if available
    try {
      return scan.getLatLng();
    } catch (_) {
      // fallback: try parsing the valor field if it's geo:lat,lng
      final v = scan.valor ?? '';
      if (v.toLowerCase().startsWith('geo')) {
        final coordPart = v.contains(':')
            ? v.split(':').sublist(1).join(':')
            : v;
        final parts = coordPart.split(',');
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        return LatLng(lat, lng);
      }
      throw Exception('No coordinates found');
    }
  }
}

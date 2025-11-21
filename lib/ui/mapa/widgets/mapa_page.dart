import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_reader/app_export.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final Completer<GoogleMapController> _controller = Completer();
  MapType mapType = MapType.normal;

  LatLng? _scannedLatLng;
  String _scannedValor = '';
  String _tipo = 'geo';

  Position? _myPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMyLocation();
  }

  Future<void> _initMyLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // permission not granted, just return (map will show scanned point)
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      _myPosition = pos;

      final myLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _markers.removeWhere((m) => m.markerId == const MarkerId('me'));
        _markers.add(
          Marker(
            markerId: const MarkerId('me'),
            position: myLatLng,
            infoWindow: const InfoWindow(title: 'Mi ubicación'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      });

      // If scanned point already available, fit bounds now
      if (_scannedLatLng != null && _controller.isCompleted) {
        final controller = await _controller.future;
        await _fitBounds(controller, _scannedLatLng!, myLatLng);
      }
    } catch (_) {
      // ignore location errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read route arguments once and store in state (avoid repeated parsing)
    final args = ModalRoute.of(context)!.settings.arguments;
    if (_scannedLatLng == null) {
      if (args is ScanModel) {
        _tipo = args.tipo ?? 'geo';
        _scannedValor = args.valor ?? '';
        try {
          _scannedLatLng = _getLatLngFromScan(args);
        } catch (_) {
          _scannedLatLng = null;
        }
      } else if (args is String &&
          args.trim().toLowerCase().startsWith('geo')) {
        final s = args.trim();
        final coordPart = s.contains(':')
            ? s.split(':').sublist(1).join(':')
            : s;
        final parts = coordPart.split(',');
        if (parts.length >= 2) {
          try {
            final lat = double.parse(parts[0].trim());
            final lng = double.parse(parts[1].trim());
            _scannedLatLng = LatLng(lat, lng);
            _scannedValor = 'geo:$lat,$lng';
            _tipo = 'geo';
          } catch (_) {
            _scannedLatLng = null;
          }
        }
      }
      // Add scanned marker if parsed
      if (_scannedLatLng != null) {
        _markers.removeWhere(
          (m) =>
              m.markerId ==
              MarkerId(
                _scannedValor.isNotEmpty
                    ? _scannedValor
                    : '${_scannedLatLng!.latitude},${_scannedLatLng!.longitude}',
              ),
        );
        _markers.add(
          Marker(
            markerId: MarkerId(
              _scannedValor.isNotEmpty
                  ? _scannedValor
                  : '${_scannedLatLng!.latitude},${_scannedLatLng!.longitude}',
            ),
            position: _scannedLatLng!,
            infoWindow: InfoWindow(title: _scannedValor, snippet: _tipo),
          ),
        );
      }
    }

    if (_scannedLatLng == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: const Center(child: Text('No se proporcionó scan válido')),
      );
    }

    final puntoInicial = CameraPosition(target: _scannedLatLng!, zoom: 17);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa - $_tipo'),
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
        markers: _markers,
        onMapCreated: (GoogleMapController controller) async {
          if (!_controller.isCompleted) _controller.complete(controller);
          // If both scanned point and my position present, fit bounds
          if (_myPosition != null && _scannedLatLng != null) {
            await _fitBounds(
              controller,
              _scannedLatLng!,
              LatLng(_myPosition!.latitude, _myPosition!.longitude),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () async {
          final controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLng(_scannedLatLng!));
        },
      ),
    );
  }

  Future<void> _fitBounds(
    GoogleMapController controller,
    LatLng a,
    LatLng b,
  ) async {
    final south = LatLng(
      a.latitude < b.latitude ? a.latitude : b.latitude,
      a.longitude < b.longitude ? a.longitude : b.longitude,
    );
    final north = LatLng(
      a.latitude > b.latitude ? a.latitude : b.latitude,
      a.longitude > b.longitude ? a.longitude : b.longitude,
    );
    final bounds = LatLngBounds(southwest: south, northeast: north);
    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (_) {
      // on some devices newLatLngBounds may throw if map not fully ready - ignore
    }
  }

  LatLng _getLatLngFromScan(ScanModel scan) {
    try {
      return scan.getLatLng();
    } catch (_) {
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

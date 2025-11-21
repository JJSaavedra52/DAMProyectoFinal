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
    // Expecting a ScanModel passed as argument
    final scan = ModalRoute.of(context)!.settings.arguments as ScanModel;

    final LatLng latLng = getLatLng(scan);
    final puntoInicial = CameraPosition(target: latLng, zoom: 17);

    final markers = <Marker>{
      Marker(
        markerId: MarkerId(scan.id.toString()),
        position: latLng,
        infoWindow: InfoWindow(title: scan.valor, snippet: scan.tipo),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa - ${scan.tipo}'),
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

  LatLng getLatLng(ScanModel scan) {
    if (scan.tipo == "geo") {
      return scan.getLatLng();
    } else if (scan.tipo == "otro") {
      // adapt as needed
      return scan.getLatLng();
    }
    throw "ha ocurrido un error";
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPuntoAPunto extends StatefulWidget {
  const MapPuntoAPunto({super.key});

  @override
  createState() => _MapScreenState();
}

class _MapScreenState extends State<MapPuntoAPunto> {
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? pointA, pointB;

  @override
  void initState() {
    super.initState();
  }
/*
  // Agregar punto B al hacer tap en el mapa
  void _onMapTapped(LatLng location) {
    setState(() {
      pointB = location;

      // Limpiar marcadores anteriores de punto B
      markers.removeWhere((marker) => marker.markerId.value == 'pointB');

      // Agregar marcador punto B
      markers.add(
        Marker(
          markerId: MarkerId('pointB'),
          position: pointB!,
          infoWindow: InfoWindow(title: 'Punto B'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Si tenemos ambos puntos, calcular ruta
      if (pointA != null && pointB != null) {
        _getRouteDirections(pointA!, pointB!);
      }
    });
  }*/
/*
  // Obtener direcciones y ruta entre puntos
  Future<void> _getRouteDirections(LatLng origin, LatLng destination) async {
    final String apiKey = 'AIzaSyDQZ6vfLniJwM7ZoYOB5mHwldcCTvFrtEM';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        // Decodificar poliLínea
        List<PointLatLng> points = _decodePolyline(
            data['routes'][0]['overview_polyline']['points']
        );

        // Crear lista de LatLng para el Polyline
        List<LatLng> polylineCoordinates = points.map((point) {
          return LatLng(point.latitude, point.longitude);
        }).toList();

        setState(() {
          polylines.clear();
          polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
        });

        // Ajustar cámara para mostrar toda la ruta
        _fitRouteToScreen(polylineCoordinates);
      }
    } catch (e) {
      debugPrint('Error obteniendo ruta: $e');
    }
  }
*/

  // Decodificar poliLínea (algoritmo de Google Maps)
  List<PointLatLng> _decodePolyline(String encoded) {
    List<PointLatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(PointLatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // Ajustar cámara para mostrar toda la ruta
  void _fitRouteToScreen(List<LatLng> polylineCoordinates) {
    if (polylineCoordinates.isEmpty) return;

    double minLat = polylineCoordinates[0].latitude;
    double maxLat = polylineCoordinates[0].latitude;
    double minLng = polylineCoordinates[0].longitude;
    double maxLng = polylineCoordinates[0].longitude;

    for (final point in polylineCoordinates) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {

    // Limpiar marcadores anteriores de punto B
    markers.removeWhere((marker) => marker.markerId.value == 'pointB');

    Map pointsMap = ModalRoute.of(context)!.settings.arguments as Map<String, LatLng>;
    pointB = pointsMap["pointB"];
    pointA = pointsMap["pointA"];
    final initialPosition = CameraPosition(
      target: pointsMap["pointA"],
      zoom: 12.5,
      tilt: 50,
    );

    // Agregar marcador punto A
    markers.add(
      Marker(
        markerId: MarkerId('pointA'),
        position: pointA!,
        infoWindow: InfoWindow(title: 'Punto A'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Agregar marcador punto B
    markers.add(
      Marker(
        markerId: MarkerId('pointB'),
        position: pointB!,
        infoWindow: InfoWindow(title: 'Punto B'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Punto A a Punto B'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: initialPosition,
        markers: markers,
        polylines: polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 10),
          if (pointA != null && pointB != null)
            FloatingActionButton(
              onPressed: () {
                // Aquí puedes agregar funcionalidad adicional
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Ruta Calculada'),
                    content: Text('Punto A a Punto B conectados'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Icon(Icons.directions),
            ),
        ],
      ),
    );
  }
}

// Clase auxiliar para puntos de lat/lng
class PointLatLng {
  final double latitude;
  final double longitude;

  PointLatLng(this.latitude, this.longitude);
}
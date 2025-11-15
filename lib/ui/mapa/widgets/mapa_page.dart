/*
import 'package:flutter/material.dart';

class MapaPage extends StatelessWidget {
   
  const MapaPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
         child: Text('MapaPage'),
      ),
    );
  }
}
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:qr_reader/app_export.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapaPageState createState() => _MapaPageState();

  //State<MapaPage> createState() => _MapaSampleState();
}

class _MapaPageState extends State<MapaPage> {
  final Completer<GoogleMapController> _controller = Completer();
  MapType mapType = MapType.normal;

  @override
  Widget build(BuildContext context) {

    //final ScanModel scan = ModalRoute.of(context).settings.arguments;
    final scan = ModalRoute.of(context)!.settings.arguments as ScanModel;

    //final args = ModalRoute.of(context)?.settings.arguments;
    //if (args is ScanModel) {

    final CameraPosition puntoInicial = CameraPosition(
      //target: LatLng(37.43296265331129, -122.08832357078792),
      target: getLatLng(scan),
      zoom: 17.5,
      tilt: 50,
    );

    // Marcadores
    //Set<Marker> markers = Set<Marker>();
    Set<Marker> markers = <Marker>{};
    
    markers.add(
      Marker(
        markerId: MarkerId('geo-location'),
        position: getLatLng(scan)
        //position: LatLng(37.43296265331129, -122.08832357078792),
      ),
    );
    //}

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_disabled),
            onPressed: () async {
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: getLatLng(scan),
                    //target: LatLng(37.43296265331129, -122.08832357078792),
                    zoom: 17.5,
                    tilt: 50,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        mapType: mapType,
        markers: markers,
        initialCameraPosition: puntoInicial,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.layers),
        onPressed: () {
          if (mapType == MapType.normal) {
            mapType = MapType.satellite;
          } else {
            mapType = MapType.normal;
          }

          setState(() {});
        },
      ),
    );
  }

  LatLng getLatLng(ScanModel scan){
    if (scan.tipo == "geo"){
      return scan.getLatLng();
    }else if (scan.tipo == "otro"){
      return scan.getLocation();
    }
    throw "ha ocurrido un error";
  }
}

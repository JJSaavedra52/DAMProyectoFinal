// To parse this JSON data, do
//
//     final scanModel = scanModelFromJson(jsonString);

/*
https://app.quicktype.io/

{
  "id": 1,
  "tipo": "http",
  "valor":"unvalor"
}
*/

/*
// To parse this JSON data, do
//
//     final scanModel = scanModelFromJson(jsonString);

import 'dart:convert';

ScanModel scanModelFromJson(String str) => ScanModel.fromJson(json.decode(str));

String scanModelToJson(ScanModel data) => json.encode(data.toJson());

class ScanModel {
    int id;
    String tipo;
    String valor;

    ScanModel({
        required this.id,
        required this.tipo,
        required this.valor,
    });

    factory ScanModel.fromJson(Map<String, dynamic> json) => ScanModel(
        id: json["id"],
        tipo: json["tipo"],
        valor: json["valor"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "tipo": tipo,
        "valor": valor,
    };
}*/

import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

ScanModel scanModelFromJson(String str) => ScanModel.fromJson(json.decode(str));
String scanModelToJson(ScanModel data) => json.encode(data.toJson());

class ScanModel {

    int? id;
    String? tipo;
    String valor;
    String? location;
   
    ScanModel({
        this.id,
        this.tipo,
        location,
        required this.valor,
    }) {

      if ( valor.contains('http') ) {
        tipo = 'http';
      } else if ( valor.contains('geo') ) {
         tipo = 'geo';
      } else{
        tipo = 'otro';
        this.location = location;
      }
    }

    LatLng getLocation(){
      final latLng = location!.substring(4).split(',');
      final lat = double.parse( latLng[0] );
      final lng = double.parse( latLng[1] );

      return LatLng( lat, lng );
    }

    LatLng getLatLng() {

      final latLng = valor.substring(4).split(',');
      final lat = double.parse( latLng[0] );
      final lng = double.parse( latLng[1] );

      return LatLng( lat, lng );
    }

    factory ScanModel.fromJson(Map<String, dynamic> json ) => ScanModel(
        id: json["id"],
        tipo: json["tipo"],
        valor: json["valor"],
        location: json["location"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "tipo": tipo,
        "valor": valor,
        "location": location,
    };

}



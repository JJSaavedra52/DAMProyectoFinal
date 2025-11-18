import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime? timestamp;

  AppLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
  });

  // Convertir de Position a AppLocation
  factory AppLocation.fromPosition(Position position) {
    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  // Convertir a LatLng para Google Maps
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  String toJson() {
    return '{latitude: $latitude, longitude: $longitude}';
  }

  @override
  String toString() {
    return "geo:$latitude,$longitude";
  }
}
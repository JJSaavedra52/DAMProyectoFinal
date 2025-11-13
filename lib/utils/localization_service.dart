import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Instancia singleton
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Obtiene la ubicación actual una vez
  Future<Position?> getCurrentLocation() async {
    try {
      // Verificar y solicitar permisos
      final permissionStatus = await _checkLocationPermission();

      if (permissionStatus != LocationPermission.always &&
          permissionStatus != LocationPermission.whileInUse) {
        return null;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 15), // Timeout de 15 segundos
      );

      return position;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Verifica y solicita permisos de ubicación
  Future<LocationPermission> _checkLocationPermission() async {
    // Verificar si los permisos están denegados
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Solicitar permisos
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permisos denegados por el usuario
        return LocationPermission.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permisos denegados permanentemente
      return LocationPermission.deniedForever;
    }

    return permission;
  }

  /// Verifica si el GPS está activado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtiene la última ubicación conocida (más rápida)
  Future<Position?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      print('Error obteniendo última ubicación conocida: $e');
      return null;
    }
  }

  /// Calcula distancia entre dos puntos
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
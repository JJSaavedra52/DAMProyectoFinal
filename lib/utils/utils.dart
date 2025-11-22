import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_reader/app_export.dart';
import 'package:url_launcher/url_launcher.dart';

/*
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
*/

Future<void> launchURL(BuildContext context, ScanModel scan) async {
  final url = scan.valor;
  final Uri uriUrl = Uri.parse(url);
  if (scan.tipo == 'http') {
    if (!await launchUrl(uriUrl)) {
      throw Exception('Could not launch  $uriUrl');
    }
  } else if (scan.tipo == 'geo') {
    final pointA = (await ScanListProvider.geoLocalizar()).toLatLng();
    final pointB = scan.getLatLng();
    Map<String, LatLng> exports = {
      "pointA":pointA,
      "pointB":pointB
    };
    Navigator.pushNamed(context, 'mapa_punto_a_punto', arguments: exports);
  } else if (scan.tipo == 'otro') {
    Navigator.pushNamed(context, 'mapa', arguments: scan);
  } else {
    throw Exception('Could not launch $uriUrl');
  }
}

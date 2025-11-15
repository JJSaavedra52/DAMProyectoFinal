import 'package:flutter/material.dart';
import 'package:qr_reader/domain/providers/db_provider.dart';
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
    // Abrir el sitio web

    if (!await launchUrl(uriUrl)) {
      throw Exception('Could not launch $uriUrl');
    }

    /*
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    */
    
  } else if (scan.tipo == 'geo' || scan.tipo == 'otro') {
     Navigator.pushNamed(context, 'mapa', arguments: scan);
  } else {
    throw Exception('Could not launch $uriUrl');

  }
}

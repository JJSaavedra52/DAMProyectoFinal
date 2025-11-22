import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_reader/app_export.dart';
import 'package:qr_reader/domain/providers/api_provider.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  late Future<List<Scan>> _futureScans;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  void _loadScans() {
    _futureScans = ApiProvider().getMyScans();
  }

  Future<void> _refresh() async {
    setState(() => _loadScans());
    await _futureScans;
  }

  String _scanDate(Scan s) {
    // Api Scan has no explicit date in your model; adapt if backend returns a date field
    // If backend uses another field name (e.g. createdAt), parse it here:
    return s.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de lecturas')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Scan>>(
          future: _futureScans,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            final scans = snap.data ?? [];
            if (scans.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No hay lecturas en la BD remota')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: scans.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final s = scans[i];
                final valor = s.valor;
                final tipo = s.tipo;
                return ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text(valor),
                  subtitle: Text(_scanDate(s)),
                  trailing: Text(tipo),
                  onTap: () async{
                    // Prefer sending the raw geo string so mapa_page parses it reliably.
                    final geo = s.valor ?? s.location ?? s.toString();
                    // optional: debug print to verify
                    // debugPrint('Opening mapa with: $geo');
                    final scanListProvider = ScanListProvider();
                    final nuevoScan = await scanListProvider.nuevoScan(s.valor!);
                    final pointA = (await ScanListProvider.geoLocalizar()).toLatLng();
                    final pointB = nuevoScan.getLatLng();
                    Map<String, LatLng> exports = {
                    "pointA":pointA,
                    "pointB":pointB
                    };
                    Navigator.pushNamed(context, 'mapa_punto_a_punto', arguments: exports);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

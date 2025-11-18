import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/app_export.dart';

class ScanTiles extends StatelessWidget {
  final String tipo;
  const ScanTiles({super.key,  required this.tipo });

  @override
  Widget build(BuildContext context) {
    final scanListProvider = Provider.of<ScanListProvider>(context);
    final scans = scanListProvider.scans;

    return ListView.builder(
      itemCount: scans.length,
      itemBuilder: ( _, i ) => Dismissible(
        key: UniqueKey(),
        background: Container(
          color: Colors.red,
        ),
        onDismissed: (DismissDirection direction) {
          
          final int? j = scans[i].id;

          if (j != null){
          Provider.of<ScanListProvider>(context, listen: false)
              .borrarScanPorId(j);
          }
          
        },
        child: ListTile(
          leading: Icon( 
            tipo == 'http'
              ? Icons.home_outlined
              : Icons.map_outlined, 
            color: Theme.of(context).primaryColor 
          ),
          title: Text( scans[i].valor ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (Text( "${scans[i].id}\t")),
              if (scans[i].location != null) (Text( scans[i].location! ))
            ],
          ),
          trailing: Icon( Icons.keyboard_arrow_right, color: Colors.grey ),
          onTap: () => launchURL(context, scans[i]),
        ),
      )
    );
  }
}
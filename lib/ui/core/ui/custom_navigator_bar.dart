import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/app_export.dart';

class CustomNavigatorBar extends StatelessWidget {
  const CustomNavigatorBar({super.key});

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final currentIndex = uiProvider.selectedMenuOpt;

    //return const Placeholder();
    return BottomNavigationBar(
      onTap: ( int i ) => uiProvider.selectedMenuOpt = i,
      //currentIndex: 0,
      currentIndex: currentIndex ,
      elevation: 0,
      unselectedItemColor: Theme.of(context).primaryColor,
      selectedItemColor: Colors.white,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.map, color: Theme.of(context).primaryColor,),
          label: 'Mapa'),
        BottomNavigationBarItem(
          icon: Icon(Icons.compass_calibration, color: Theme.of(context).primaryColor,),
          label: 'Direcciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pedal_bike, color: Theme.of(context).primaryColor,),
          label: 'Otra Opcion',
        ),
      ],
    );
  }
}

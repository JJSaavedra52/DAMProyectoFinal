//fls
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/app_export.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        elevation: 0,
        title: Text('Historial'),
        centerTitle: true,
                
        backgroundColor: Colors.deepPurple,

        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever,color: Colors.red),
            onPressed: () {
              Provider.of<ScanListProvider>(context, listen: false)
                .borrarTodos();
            },
          ),
        ],
      ),
      
      //body: Center(child: Text('Home Page')),
      
      //body: MapasPage(),
      //body: DireccionesPage(),

      body: _HomePageBody(),



      bottomNavigationBar: CustomNavigatorBar(),

      floatingActionButton: ScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}

class _HomePageBody extends StatelessWidget {
  
  const _HomePageBody({super.key});

  @override
  Widget build(BuildContext context) {

    /*
    return Container(
      child: Text('Algo'),
    );
    */


    // Obtener el selected menu opt
    final uiProvider = Provider.of<UiProvider>(context);
    
    // Cambiar para mostrar la pagina respectiva
    final currentIndex = uiProvider.selectedMenuOpt;


    //final currentIndex = 1;


    //final currentIndex = uiProvider.selectedMenuOpt;

    // Usar el ScanListProvider
    final scanListProvider = Provider.of<ScanListProvider>(context, listen: false);

    switch( currentIndex ) {

      case 0:
        scanListProvider.cargarScanPorTipo('geo');
        return MapasPage();

      case 1: 
        scanListProvider.cargarScanPorTipo('http');
        return DireccionesPage();

      case 2: 
        scanListProvider.cargarScanPorTipo('otro');
        return OtraPage();

      default:
        return MapasPage();
    }


  }
}

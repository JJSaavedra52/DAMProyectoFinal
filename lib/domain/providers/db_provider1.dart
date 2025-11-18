import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:qr_reader/app_export.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider1 {
  static late Database _database;
  static final DBProvider1 db = DBProvider1._();
  DBProvider1._();

  //static late Database db;

  Future<Database> get database async {
    //if(_database != null) return _database;

    // Get a location using getDatabasesPath
    try {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'ScansDB.db');

      /*
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final path1 = join(documentsDirectory.path, 'ScansDB.db');
      print(path1);
      */

      debugPrint(path);

      _database = await open(path);

      return _database;
    } catch (ex){
      throw Exception("No se conectó a la bd");
    }
  }

  Future open(String path) async {
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Scans(
            id INTEGER PRIMARY KEY,
            tipo TEXT,
            valor TEXT,
            location TEXT
          )
        ''');
      },
    );
  }

  Future<int> nuevoScanRaw(ScanModel nuevoScan) async {
    final id = nuevoScan.id;
    final tipo = nuevoScan.tipo;
    final valor = nuevoScan.valor;
    final location = nuevoScan.location;

    // Verificar la base de datos
    final db = await database;

    final res = await db.rawInsert('''
      INSERT INTO Scans( id, tipo, valor, location )
        VALUES( $id, '$tipo', '$valor', '$location' )
    ''');

    return res;
  }

  Future<int> nuevoScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = await db.insert('Scans', nuevoScan.toJson());

    // Es el ID del último registro insertado;
    return res;
  }

  Future<int> updateScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = await db.update(
      'Scans',
      nuevoScan.toJson(),
      where: 'id = ?',
      whereArgs: [nuevoScan.id],
    );
    return res;
  }

  Future<int> deleteScan(int id) async {
    final db = await database;
    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);
    return res;
  }

  Future<int> deleteAllScans() async {
    final db = await database;
    final res = await db.rawDelete('''
      DELETE FROM Scans    
    ''');
    return res;
  }

  Future<ScanModel?> getScanById(int id) async {
    final db = await database;
    final res = await db.query('Scans', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? ScanModel.fromJson(res.first) : null;
  }

  Future<List<ScanModel>> getTodosLosScans() async {
    final db = await database;
    final res = await db.query('Scans');

    return res.isNotEmpty ? res.map((s) => ScanModel.fromJson(s)).toList() : [];
  }

  Future<List<ScanModel>> getScansPorTipo(String tipo) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT * FROM Scans WHERE tipo = '$tipo'    
    ''');

    return res.isNotEmpty ? res.map((s) => ScanModel.fromJson(s)).toList() : [];
  }

  Future close() async => db.close();

}

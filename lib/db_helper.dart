// ignore_for_file: unnecessary_null_comparison, depend_on_referenced_packages, unused_import, prefer_final_fields

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  String expenseDatabaseName = "expenseDatabase2";
  String expenseTableName = "expense2";
  int _version = 1;
  late Database database;

  Future<void> open() async {
    database = await openDatabase(expenseDatabaseName, version: _version,
        onCreate: (db, version) {
      db.execute(
          "CREATE TABLE $expenseTableName (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, expenseName TEXT, expenseDate TEXT, expense REAL)");
    });
  }

  Future<void> addData(String category, String expenseName, String expenseDate,
      double expense) async {
    // Veritabanını aç
    if (database == null) {
      await open(); // Eğer veritabanı henüz açılmamışsa aç
    }

    // Veritabanına yeni veri ekle
    await database.insert(
      expenseTableName,
      {
        'category': category,
        'expenseName': expenseName,
        'expenseDate': expenseDate,
        'expense': expense,
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Eğer aynı id ile kayıt varsa güncelle
    );
  }

  Future<List<Map<String, dynamic>>> getData() async {
    // Veritabanını aç
    if (database == null) {
      await open(); // Eğer veritabanı henüz açılmamışsa aç
    }

    // Tüm gider verilerini al
    List<Map<String, dynamic>> result = await database.query(expenseTableName);

    return result;
  }
}

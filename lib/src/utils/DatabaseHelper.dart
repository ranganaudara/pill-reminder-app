import 'dart:io';
import 'dart:typed_data';

import 'package:drug_alarm/src/models/ReminderModel.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper{
  var database;
  static final DatabaseHelper _databaseHelper = DatabaseHelper._internal();

  factory DatabaseHelper() => _databaseHelper;

  DatabaseHelper._internal() {
    this.database = loadDatabase();
  }

  Future<Database> loadDatabase() async {
    var dbInstance;
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "reminder_database.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "reminder_database.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    // open the database
    dbInstance = await openDatabase(path, readOnly: false);

    return dbInstance;
  }

  Future<List<Reminder>> getAllReminders() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('reminder_table');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  Future addReminder(Reminder reminder) async {
    final db = await database;
    var res;
      var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM reminder_table");

      int id = table.first["id"];

      res = await db.rawInsert(
          "INSERT Into reminder_table (id,drugName, days, time, numberOfPills)"
              " VALUES (?,?,?,?,?)",
          [id, reminder.drugName, reminder.days, reminder.time,reminder.numberOfPills]);
    return res;
  }

  Future deleteReminder(Reminder reminder) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.execute("DELETE FROM reminder_table WHERE id = '${reminder.id}'");
      print("Successfully deleted: ${reminder.id}");
    });
  }

}

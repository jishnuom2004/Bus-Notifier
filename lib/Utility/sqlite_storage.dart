import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class SqliteStorage {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  static Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'bus_details.db');

    return openDatabase(
      path,
      version: 3, // Increment version to trigger onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bus_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        busStop TEXT,
        busName TEXT,
        busTimeFrom TEXT,
        busTimeTill TEXT,
        days TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE bus_stops (
        stopName TEXT PRIMARY KEY
      )
    ''');
    await db.execute('''
      CREATE TABLE bus_names (
        busName TEXT PRIMARY KEY
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE bus_stops (
          stopName TEXT PRIMARY KEY
        )
      ''');
      await db.execute('''
        CREATE TABLE bus_names (
          busName TEXT PRIMARY KEY
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT
        )
      ''');
    }
  }

  static Future<void> insertBusStop(String stopName) async {
    final db = await database;
    await db.insert(
      'bus_stops',
      {'stopName': stopName},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore duplicates
    );
  }

  static Future<void> insertBusName(String busName) async {
    final db = await database;
    await db.insert(
      'bus_names',
      {'busName': busName},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore duplicates
    );
  }

  static Future<List<String>> getBusStops() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bus_stops');
    return List.generate(maps.length, (i) => maps[i]['stopName'] as String);
  }

  static Future<List<String>> getBusNames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bus_names');
    return List.generate(maps.length, (i) => maps[i]['busName'] as String);
  }

  static Future<int?> insertBusDetail(Map<String, dynamic> busDetail) async {
    final db = await database;

    if (await isDuplicate(busDetail)) {
      print("Duplicate entry found. Not inserting.");
      return null; // Indicate that the insertion was not successful
    }

    return await db.insert('bus_details', {
      'busStop': busDetail['busStop'],
      'busName': busDetail['busName'],
      'busTimeFrom': busDetail['busTimeFrom'],
      'busTimeTill': busDetail['busTimeTill'],
      'days': jsonEncode(busDetail['days']), // Store the list as a JSON string
    });
  }

  static Future<bool> isDuplicate(Map<String, dynamic> busDetail) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'bus_details',
      where: 'busStop = ? AND busName = ? AND busTimeFrom = ? AND busTimeTill = ? AND days = ?',
      whereArgs: [
        busDetail['busStop'],
        busDetail['busName'],
        busDetail['busTimeFrom'],
        busDetail['busTimeTill'],
        jsonEncode(busDetail['days']),
      ],
    );
    return result.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getBusDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bus_details');

    // Decode the 'days' field from JSON
    return maps.map((map) {
      return {
        'id': map['id'],
        'busStop': map['busStop'],
        'busName': map['busName'],
        'busTimeFrom': map['busTimeFrom'],
        'busTimeTill': map['busTimeTill'],
        'days': jsonDecode(map['days'] as String), // Decode the JSON string
      };
    }).toList();
  }

  static Future<int> deleteBusDetail(int id) async {
    final db = await database;
    return await db.delete(
      'bus_details',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateBusDetail(Map<String, dynamic> busDetail) async {
    final db = await database;
    return await db.update(
      'bus_details',
      {
        'busName': busDetail['busName'],
        'busTimeFrom': busDetail['busTimeFrom'],
        'busTimeTill': busDetail['busTimeTill'],
        'days': jsonEncode(busDetail['days']), // Encode the list as a JSON string
      },
      where: 'id = ?',
      whereArgs: [busDetail['id']],
    );
  }


}
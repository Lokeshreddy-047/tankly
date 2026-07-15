import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fuel_log.dart';
import '../models/maintenance_log.dart';
import '../models/reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Incremented to trigger migration on existing installs
  static const _databaseVersion = 2;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tankly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // The new migration path
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE fuel_logs ADD COLUMN isFullTank INTEGER NOT NULL DEFAULT 1');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fuel_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        odometer REAL,
        litres REAL,
        pricePerLitre REAL,
        totalAmount REAL NOT NULL,
        date TEXT NOT NULL,
        isFullTank INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serviceType TEXT NOT NULL,
        odometer REAL NOT NULL,
        cost REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        dueOdometer REAL,
        dueDate TEXT
      )
    ''');
  }

  // --- Fuel Log Methods ---
  Future<int> insertFuelLog(FuelLog log) async {
    final db = await instance.database;
    return await db.insert('fuel_logs', log.toMap());
  }

  Future<List<FuelLog>> getAllFuelLogs() async {
    final db = await instance.database;
    final result = await db.query('fuel_logs', orderBy: 'date DESC');
    return result.map((json) => FuelLog.fromMap(json)).toList();
  }

  Future<int> deleteFuelLog(int id) async {
    final db = await instance.database;
    return await db.delete('fuel_logs', where: 'id = ?', whereArgs: [id]);
  }

  // --- Maintenance Log Methods ---
  Future<int> insertMaintenanceLog(MaintenanceLog log) async {
    final db = await instance.database;
    return await db.insert('maintenance_logs', log.toMap());
  }

  Future<List<MaintenanceLog>> getAllMaintenanceLogs() async {
    final db = await instance.database;
    final result = await db.query('maintenance_logs', orderBy: 'date DESC');
    return result.map((json) => MaintenanceLog.fromMap(json)).toList();
  }

  Future<int> deleteMaintenanceLog(int id) async {
    final db = await instance.database;
    return await db.delete('maintenance_logs', where: 'id = ?', whereArgs: [id]);
  }

  // --- Reminder Methods ---
  Future<int> insertReminder(Reminder reminder) async {
    final db = await instance.database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await instance.database;
    final result = await db.query('reminders', orderBy: 'dueDate ASC');
    return result.map((json) => Reminder.fromMap(json)).toList();
  }

  Future<int> deleteReminder(int id) async {
    final db = await instance.database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/trip.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'natpac_travel.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT UNIQUE NOT NULL,
        age_group TEXT,
        gender TEXT,
        household_size INTEGER,
        consent_given INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create trips table
    await db.execute('''
      CREATE TABLE trips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        trip_number INTEGER NOT NULL,
        origin_lat REAL,
        origin_lng REAL,
        origin_address TEXT,
        destination_lat REAL,
        destination_lng REAL,
        destination_address TEXT,
        start_time TEXT,
        end_time TEXT,
        mode_of_travel TEXT,
        num_co_travellers INTEGER NOT NULL DEFAULT 0,
        co_traveller_relationships TEXT,
        is_confirmed INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toJson());
  }

  Future<User?> getUserByDeviceId(String deviceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Trip operations
  Future<int> insertTrip(Trip trip) async {
    final db = await database;
    return await db.insert('trips', trip.toJson());
  }

  Future<List<Trip>> getUserTrips(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Trip.fromJson(maps[i]);
    });
  }

  Future<Trip?> getTripById(int tripId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [tripId],
    );

    if (maps.isNotEmpty) {
      return Trip.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateTrip(Trip trip) async {
    final db = await database;
    return await db.update(
      'trips',
      trip.toJson(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<int> deleteTrip(int tripId) async {
    final db = await database;
    return await db.delete(
      'trips',
      where: 'id = ?',
      whereArgs: [tripId],
    );
  }

  Future<List<Trip>> getUnsyncedTrips(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'user_id = ? AND is_synced = ?',
      whereArgs: [userId, 0],
    );

    return List.generate(maps.length, (i) {
      return Trip.fromJson(maps[i]);
    });
  }

  Future<void> markTripsAsSynced(List<int> tripIds) async {
    final db = await database;
    for (int tripId in tripIds) {
      await db.update(
        'trips',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [tripId],
      );
    }
  }

  Future<int> getNextTripNumber(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT MAX(trip_number) as max_number FROM trips WHERE user_id = ?',
      [userId],
    );
    
    int maxNumber = result.first['max_number'] as int? ?? 0;
    return maxNumber + 1;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

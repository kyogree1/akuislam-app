import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDB {
  static final AppDB instance = AppDB._init();
  static Database? _database;
  static Future<Database>? _opening;
  static final List<Map<String, dynamic>> _memoryBookmarks = [];
  static int _memoryIdCounter = 1;
  static final List<Map<String, dynamic>> _memoryHistory = [];
  static int _memoryHistoryIdCounter = 1;

  AppDB._init();

  Future<Database> get database {
    final db = _database;
    if (db != null) return Future.value(db);
    // Single-flight: beberapa pemanggil bersamaan berbagi satu proses buka DB.
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    try {
      final db = await _initDB('akumuslim.db');
      _database = db;
      return db;
    } finally {
      _opening = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await _createHistoryTable(db);
        if (oldVersion < 3) await _dedupeBookmarks(db);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // ponytail: kolom ayat dibiarkan (nullable, tak dipakai) agar tidak perlu migrasi; drop saat DB v4.
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        surah_latin TEXT,
        ayat INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await _createHistoryTable(db);
    await _createBookmarkIndex(db);
  }

  Future _dedupeBookmarks(Database db) async {
    await db.execute('''
      DELETE FROM bookmarks
      WHERE id NOT IN (SELECT MIN(id) FROM bookmarks GROUP BY surah_id)
    ''');
    await _createBookmarkIndex(db);
  }

  Future _createBookmarkIndex(Database db) async {
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS bookmarks_surah_id ON bookmarks(surah_id)',
    );
  }

  Future _createHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER NOT NULL UNIQUE,
        surah_name TEXT NOT NULL,
        last_read_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> addBookmark({
    required int surahId,
    required String surahName,
  }) async {
    if (kIsWeb) {
      if (_memoryBookmarks.any((item) => item['surah_id'] == surahId)) return 0;
      final id = _memoryIdCounter++;
      _memoryBookmarks.insert(0, {
        'id': id,
        'surah_id': surahId,
        'surah_name': surahName,
        'created_at': DateTime.now().toIso8601String(),
      });
      return id;
    }

    final db = await instance.database;
    return await db.insert('bookmarks', {
      'surah_id': surahId,
      'surah_name': surahName,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<bool> isBookmarked(int surahId) async {
    if (kIsWeb) {
      return _memoryBookmarks.any((item) => item['surah_id'] == surahId);
    }

    final db = await instance.database;
    final rows = await db.query(
      'bookmarks',
      columns: ['id'],
      where: 'surah_id = ?',
      whereArgs: [surahId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> removeBookmarkBySurah(int surahId) async {
    if (kIsWeb) {
      final before = _memoryBookmarks.length;
      _memoryBookmarks.removeWhere((item) => item['surah_id'] == surahId);
      return before - _memoryBookmarks.length;
    }

    final db = await instance.database;
    return await db.delete(
      'bookmarks',
      where: 'surah_id = ?',
      whereArgs: [surahId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    if (kIsWeb) {
      return List.from(_memoryBookmarks);
    }

    final db = await instance.database;
    return await db.query('bookmarks', orderBy: 'created_at DESC');
  }

  Future<int> deleteBookmark(int id) async {
    if (kIsWeb) {
      _memoryBookmarks.removeWhere((item) => item['id'] == id);
      return 1;
    }

    final db = await instance.database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveLastRead({
    required int surahId,
    required String surahName,
  }) async {
    final readAt = DateTime.now().toIso8601String();
    if (kIsWeb) {
      _memoryHistory.removeWhere((item) => item['surah_id'] == surahId);
      _memoryHistory.insert(0, {
        'id': _memoryHistoryIdCounter++,
        'surah_id': surahId,
        'surah_name': surahName,
        'last_read_at': readAt,
      });
      return;
    }

    final db = await instance.database;
    await db.insert('history', {
      'surah_id': surahId,
      'surah_name': surahName,
      'last_read_at': readAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    if (kIsWeb) {
      return _memoryHistory.isEmpty ? null : Map.of(_memoryHistory.first);
    }

    final db = await instance.database;
    final rows = await db.query(
      'history',
      orderBy: 'last_read_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    if (kIsWeb) return List.from(_memoryHistory);

    final db = await instance.database;
    return await db.query('history', orderBy: 'last_read_at DESC');
  }

  Future<int> deleteAllHistory() async {
    if (kIsWeb) {
      final count = _memoryHistory.length;
      _memoryHistory.clear();
      return count;
    }

    final db = await instance.database;
    return await db.delete('history');
  }
}

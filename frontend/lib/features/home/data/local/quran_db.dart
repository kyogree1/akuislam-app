import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/asset_file.dart'
    if (dart.library.io) '../../../../core/utils/asset_file_io.dart';
import '../models/ayat_model.dart';
import '../models/surah_model_api.dart';

/// Database Al-Qur'an read-only yang dibundel sebagai aset.
/// Dibangun ulang dari tool/fetch_quran_assets.py + tool/build_quran_db.py.
class QuranDb {
  QuranDb._();

  static final QuranDb instance = QuranDb._();

  static const _assetPath = 'assets/quran.db';
  // Nama berversi: update data cukup naikkan versi, bookmark di akumuslim.db aman.
  static const _fileName = 'quran_v1.db';

  Database? _database;
  Future<Database>? _opening;

  Future<Database> get database {
    final db = _database;
    if (db != null) return Future.value(db);
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    try {
      final path = join(await getDatabasesPath(), _fileName);
      if (!await databaseExists(path)) {
        final data = await rootBundle.load(_assetPath);
        await writeAssetBytes(
          path,
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      }
      final db = await openDatabase(path, readOnly: true);
      _database = db;
      return db;
    } finally {
      _opening = null;
    }
  }

  Future<List<SurahModelApi>> getSurahs() async {
    final db = await database;
    final rows = await db.query('surahs', orderBy: 'nomor ASC');
    return rows
        .map(
          (row) => SurahModelApi(
            nomor: row['nomor'] as int,
            nama: (row['nama'] as String?) ?? '',
            namaLatin: (row['namaLatin'] as String?) ?? '',
            jumlahAyat: row['jumlahAyat'] as int,
            tempatTurun: (row['tempatTurun'] as String?) ?? '',
            arti: (row['arti'] as String?) ?? '',
            deskripsi: (row['deskripsi'] as String?) ?? '',
          ),
        )
        .toList();
  }

  Future<List<AyatModel>> getAyat(int surah) async {
    final db = await database;
    final rows = await db.query(
      'ayat',
      where: 'surah = ?',
      whereArgs: [surah],
      orderBy: 'nomor ASC',
    );
    return rows
        .map(
          (row) => AyatModel(
            nomorAyat: row['nomor'] as int,
            teksArab: (row['arab'] as String?) ?? '',
            teksLatin: (row['latin'] as String?) ?? '',
            teksIndonesia: (row['indo'] as String?) ?? '',
          ),
        )
        .toList();
  }
}

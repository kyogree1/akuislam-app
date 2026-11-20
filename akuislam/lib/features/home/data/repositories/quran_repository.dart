import '../local/quran_db.dart';
import '../models/ayat_model.dart';
import '../models/surah_model_api.dart';
import '../services/quran_api_service.dart';

/// Local-first: baca dari quran.db bawaan APK, API hanya cadangan.
class QuranRepository {
  QuranRepository({QuranDb? local, QuranApiService? api})
    : _local = local ?? QuranDb.instance,
      _api = api ?? QuranApiService();

  final QuranDb _local;
  final QuranApiService _api;

  Future<List<SurahModelApi>> getSurahs() async {
    try {
      final surahs = await _local.getSurahs();
      if (surahs.isNotEmpty) return surahs;
    } catch (_) {
      // DB lokal gagal dibuka: jatuh ke API.
    }
    return _api.getAllSurah();
  }

  Future<List<AyatModel>> getAyat(int nomor) async {
    try {
      final ayat = await _local.getAyat(nomor);
      if (ayat.isNotEmpty) return ayat;
    } catch (_) {
      // DB lokal gagal dibuka: jatuh ke API.
    }
    return _api.getSurahDetail(nomor);
  }
}

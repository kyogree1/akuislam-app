import '../datasources/quran_remote_data_source.dart';
import '../models/surah_model.dart';

/// Shares Quran data and pending requests across the app for this session.
class QuranRepository {
  QuranRepository(this._remoteDataSource);

  QuranRepository._shared() : _remoteDataSource = QuranRemoteDataSource();

  static final QuranRepository shared = QuranRepository._shared();

  final QuranRemoteDataSource _remoteDataSource;
  List<SurahModel>? _surahsCache;
  Future<List<SurahModel>>? _surahsRequest;
  final Map<int, List<AyatModel>> _ayatCache = {};
  final Map<int, Future<List<AyatModel>>> _ayatRequests = {};

  Future<List<SurahModel>> getSurahs({bool refresh = false}) {
    if (refresh) _surahsCache = null;
    final cached = _surahsCache;
    if (cached != null) return Future.value(cached);

    return _surahsRequest ??= _remoteDataSource.fetchSurahs().then((surahs) {
      final result = List<SurahModel>.unmodifiable(surahs);
      _surahsCache = result;
      return result;
    }).whenComplete(() => _surahsRequest = null);
  }

  Future<List<AyatModel>> getAyat(int nomorSurah, {bool refresh = false}) {
    if (refresh) _ayatCache.remove(nomorSurah);
    final cached = _ayatCache[nomorSurah];
    if (cached != null) return Future.value(cached);

    final pending = _ayatRequests[nomorSurah];
    if (pending != null) return pending;

    final request = _remoteDataSource.fetchAyat(nomorSurah).then((ayat) {
      final result = List<AyatModel>.unmodifiable(ayat);
      _ayatCache[nomorSurah] = result;
      return result;
    }).whenComplete(() => _ayatRequests.remove(nomorSurah));
    _ayatRequests[nomorSurah] = request;
    return request;
  }
}

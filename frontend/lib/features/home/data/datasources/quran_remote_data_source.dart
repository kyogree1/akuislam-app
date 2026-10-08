import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/surah_model.dart';

class QuranRemoteDataSource {
  QuranRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void dispose() {
    _client.close();
  }

  static const _baseUrl = 'https://equran.id/api/v2/surat';
  static const _timeout = Duration(seconds: 60);

  Future<List<SurahModel>> fetchSurahs() async {
    final response = await _client.get(Uri.parse(_baseUrl)).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat daftar surah (${response.statusCode})');
    }
    final body = jsonDecode(response.body);
    return (body['data'] as List)
        .whereType<Map>()
        .map((json) => SurahModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<List<AyatModel>> fetchAyat(int nomorSurah) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/$nomorSurah'))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat isi surah (${response.statusCode})');
    }
    final body = jsonDecode(response.body);
    if (body is! Map || body['data'] is! Map || body['data']['ayat'] is! List) {
      throw const FormatException('Format data ayat tidak valid');
    }
    return (body['data']['ayat'] as List)
        .whereType<Map>()
        .map((json) => AyatModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/surah_model_api.dart';
import '../models/ayat_model.dart';

class QuranApiService {
  static const _baseUrl = 'https://equran.id/api/v2';

  Future<List<SurahModelApi>> getAllSurah() async {
    final response = await http.get(Uri.parse('$_baseUrl/surat'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['data'] as List;
      return list.map((json) => SurahModelApi.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat daftar surah (${response.statusCode})');
    }
  }

  Future<List<AyatModel>> getSurahDetail(int nomor) async {
    final response = await http.get(Uri.parse('$_baseUrl/surat/$nomor'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayatList = data['data']['ayat'] as List;
      return ayatList.map((json) => AyatModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat detail surah (${response.statusCode})');
    }
  }
}

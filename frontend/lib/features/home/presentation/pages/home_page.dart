import 'package:flutter/material.dart';

import '../../data/datasources/quran_remote_data_source.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';
import 'isi_surah_page.dart';
import 'list_surah_page.dart';
import 'bookmark_page.dart';
import '../widgets/header.dart';
import '../widgets/last_read_card.dart';
import '../widgets/feature_grid.dart';
import '../widgets/list_surah.dart';
import '../widgets/quote.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final QuranRepository _repository = QuranRepository(QuranRemoteDataSource());
  List<SurahModel> _surahs = [];
  bool _isLoadingSurahs = true;
  String? _surahError;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await _repository.getSurahs();
      if (!mounted) return;
      setState(() {
        _surahs = surahs;
        _isLoadingSurahs = false;
        _surahError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingSurahs = false;
        _surahError = 'Gagal memuat daftar surah. Periksa internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(),
              const SizedBox(height: 20),
              const Text(
                'Mari awali hari dengan',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text(
                'kebaikan dan ketenangan.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const LastReadCard(),
              const SizedBox(height: 24),
              const Text(
                'Fitur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const FeatureGrid(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jelajahi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const QuranPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lihat semua →',
                      style: TextStyle(color: Color(0xFF2E6F40)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isLoadingSurahs)
                const Center(child: CircularProgressIndicator())
              else if (_surahError != null)
                TextButton.icon(
                  onPressed: _loadSurahs,
                  icon: const Icon(Icons.refresh),
                  label: Text(_surahError!),
                )
              else
                SurahListWidget(
                  surahs: _surahs.take(10).toList(),
                  onTap: (nomor, nama) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IsiSurahPage(nomorSurah: nomor, namaSurah: nama),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              const Text(
                'Inspirasi hari ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const QuoteCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (_) => const QuranPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (_) => const BookmarkPage()),
            );
          }
        },
      ),
    );
  }
}

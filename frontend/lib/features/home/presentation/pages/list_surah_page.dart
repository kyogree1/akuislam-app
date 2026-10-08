import 'package:flutter/material.dart';
import '../../data/models/surah_model.dart';
import '../../data/datasources/quran_remote_data_source.dart';
import '../../data/repositories/quran_repository.dart';
import 'isi_surah_page.dart';
import '../widgets/bottom_nav.dart';
import 'bookmark_page.dart';
import 'home_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final QuranRepository _repository =
      QuranRepository(QuranRemoteDataSource());
  List<SurahModel> _allSurah = [];
  List<SurahModel> _filteredSurah = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSurah();
  }

  Future<void> _fetchSurah() async {
    try {
      final surahList = await _repository.getSurahs();
      if (!mounted) return;
      setState(() {
        _allSurah = surahList;
        _filteredSurah = surahList;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat daftar surah. Periksa internet lalu coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _filterSurah(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = _allSurah.where((surah) {
      return surah.namaLatin.toLowerCase().contains(normalizedQuery) ||
          surah.nomor.toString() == normalizedQuery;
    }).toList();

    setState(() {
      _filteredSurah = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAD8),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (_) => const BookmarkPage()),
            );
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AL-QUR\'AN AL-KARIM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Daftar Surah',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _filterSurah,
                  decoration: const InputDecoration(
                    hintText: 'Cari surah atau nomor...',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vertikal List untuk halaman penuh
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E6F40)))
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage))
                        : _filteredSurah.isEmpty
                            ? const Center(child: Text('Surah tidak ditemukan.'))
                            : ListView.separated(
                            itemCount: _filteredSurah.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final surah = _filteredSurah[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3E9).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2F0EA),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${surah.nomor}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E6F40),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    surah.namaLatin,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${surah.tempatTurun} · ${surah.jumlahAyat} Ayat',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                  trailing: Text(
                                    surah.arti,
                                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => IsiSurahPage(
                                          nomorSurah: surah.nomor,
                                          namaSurah: surah.namaLatin,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
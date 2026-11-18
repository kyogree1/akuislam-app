import 'package:flutter/material.dart';

import '../../data/repositories/quran_repository.dart';
import '../../data/models/surah_model_api.dart';
import '../widgets/bottom_nav.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final _repo = QuranRepository();
  late Future<List<SurahModelApi>> _surahsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _surahsFuture = _fetchSurahs();
  }

  Future<List<SurahModelApi>> _fetchSurahs() async {
    return await _repo.getSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Daftar Surah',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: 1,
          onTap: (index) => Navigator.pushReplacementNamed(
            context,
            ['/', '/quran', '/bookmark', '/history'][index],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Cari nama surah atau arti...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _query = ''),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SurahModelApi>>(
                future: _surahsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _surahsFuture = _fetchSurahs();
                            }),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  final surahs = snapshot.data!;
                  final filteredSurahs = surahs.where((surah) {
                    final query = _query.toLowerCase();
                    return surah.namaLatin.toLowerCase().contains(query) ||
                        surah.arti.toLowerCase().contains(query);
                  }).toList();

                  if (filteredSurahs.isEmpty) {
                    return const Center(child: Text('Surah tidak ditemukan.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = filteredSurahs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE2F0EA),
                            foregroundColor: const Color(0xFF2E6F40),
                            child: Text('${surah.nomor}'),
                          ),
                          title: Text(
                            surah.namaLatin,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${surah.arti} • ${surah.jumlahAyat} ayat',
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/isi-surah',
                            arguments: {
                              'namaSurah': surah.namaLatin,
                              'nomorSurah': surah.nomor,
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

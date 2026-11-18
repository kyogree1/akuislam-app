import 'package:flutter/material.dart';

import '../../../../core/database/app_db.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/models/ayat_model.dart';
import '../widgets/bottom_nav.dart';

class IsiSurahPage extends StatefulWidget {
  const IsiSurahPage({
    super.key,
    required this.namaSurah,
    required this.nomorSurah,
  });

  final String namaSurah;
  final int nomorSurah;

  @override
  State<IsiSurahPage> createState() => _IsiSurahPageState();
}

class _IsiSurahPageState extends State<IsiSurahPage> {
  final _repo = QuranRepository();
  final _db = AppDB.instance;
  late Future<List<AyatModel>> _ayatFuture;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _ayatFuture = _fetchAyat();
    _loadBookmarkState();
  }

  Future<List<AyatModel>> _fetchAyat() async {
    final ayat = await _repo.getAyat(widget.nomorSurah);
    try {
      await _db.saveLastRead(
        surahId: widget.nomorSurah,
        surahName: widget.namaSurah,
      );
    } catch (_) {
      // Riwayat gagal disimpan tidak boleh menghalangi bacaan.
    }
    return ayat;
  }

  Future<void> _loadBookmarkState() async {
    try {
      final saved = await _db.isBookmarked(widget.nomorSurah);
      if (mounted) setState(() => _isBookmarked = saved);
    } catch (_) {
      // Status bookmark gagal dibaca: biarkan tombol dalam keadaan belum tersimpan.
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      if (_isBookmarked) {
        await _db.removeBookmarkBySurah(widget.nomorSurah);
      } else {
        await _db.addBookmark(
          surahId: widget.nomorSurah,
          surahName: widget.namaSurah,
        );
      }
      if (!mounted) return;
      setState(() => _isBookmarked = !_isBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Bookmark ditambahkan' : 'Bookmark dihapus',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan bookmark')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.namaSurah,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_added : Icons.bookmark_add,
            ),
            tooltip: _isBookmarked
                ? 'Hapus bookmark surah'
                : 'Bookmark surah ini',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) => Navigator.pushReplacementNamed(
          context,
          ['/', '/quran', '/bookmark', '/history'][index],
        ),
      ),
      body: FutureBuilder<List<AyatModel>>(
        future: _ayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _ayatFuture = _fetchAyat();
                    }),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final ayatList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: ayatList.length,
            itemBuilder: (context, index) {
              final ayat = ayatList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ayat ${ayat.nomorAyat}',
                        style: const TextStyle(
                          color: Color(0xFF2E6F40),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ayat.teksArab,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 26, height: 1.9),
                      ),
                      const Divider(height: 28),
                      Text(
                        ayat.teksIndonesia,
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

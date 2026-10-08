import 'package:flutter/material.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';

class IsiSurahPage extends StatefulWidget {
  final int nomorSurah;
  final String namaSurah;

  const IsiSurahPage({
    super.key,
    required this.nomorSurah,
    required this.namaSurah,
  });

  @override
  State<IsiSurahPage> createState() => _IsiSurahPageState();
}

class _IsiSurahPageState extends State<IsiSurahPage> {
  final QuranRepository _repository =
      QuranRepository.shared;
  List<AyatModel> _listAyat = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchIsiSurah();
  }

  Future<void> _fetchIsiSurah() async {
    try {
      debugPrint('Fetching ayat for surah ${widget.nomorSurah}...');
      final ayatList = await _repository.getAyat(widget.nomorSurah);
      debugPrint('Got ${ayatList.length} ayat');
      if (!mounted) return;
      setState(() {
        _listAyat = ayatList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching ayat: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat ayat. Periksa internet lalu coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    _fetchIsiSurah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECEAD8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.namaSurah,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        // TODO: Action button untuk play audio penuh surah (Pengembangan Lebih Lanjut)
        /*
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Color(0xFF2E6B5E)),
            onPressed: () {},
          ),
        ],
        */
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E6B5E)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _retry, child: const Text('Coba lagi')),
                    ],
                  ),
                )
              : _listAyat.isEmpty
                  ? const Center(child: Text('Belum ada data ayat.'))
                  : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: _listAyat.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final ayat = _listAyat[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCEAD9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Ayat ${ayat.nomorAyat}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E6B5E),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              // TODO: Tombol audio per ayat (Pengembangan Lebih Lanjut)
                              /*
                              IconButton(.
                                icon: const Icon(Icons.volume_up, size: 20, color: Color(0xFF2E6B5E)),
                                onPressed: () {},
                              ),
                              */
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Teks Arab
                          Text(
                            ayat.teksArab,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Terjemahan
                          Text(
                            ayat.teksIndonesia,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
    );
  }
}
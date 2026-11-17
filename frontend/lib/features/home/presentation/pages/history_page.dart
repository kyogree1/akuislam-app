import 'package:flutter/material.dart';

import '../../../../core/database/app_db.dart';
import '../../../../core/utils/relative_time.dart';
import '../widgets/bottom_nav.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _db = AppDB.instance;
  late Future<List<Map<String, dynamic>>> _history;

  @override
  void initState() {
    super.initState();
    _history = _db.getHistory();
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text(
          'Riwayat baca akan dihapus dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _db.deleteAllHistory();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus riwayat')));
      return;
    }
    if (!mounted) return;
    final history = await _db.getHistory();
    if (!mounted) return;
    setState(() => _history = Future.value(history));
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
            'History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Hapus semua riwayat',
              onPressed: _confirmClearHistory,
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _history,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data ?? const [];
            if (history.isEmpty) {
              return const Center(child: Text('Belum ada riwayat baca.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE2F0EA),
                      foregroundColor: const Color(0xFF2E6F40),
                      child: Text('${item['surah_id']}'),
                    ),
                    title: Text(
                      item['surah_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      relativeReadTime(item['last_read_at'] as String?),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF2E6F40),
                    ),
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/isi-surah',
                        arguments: {
                          'namaSurah': item['surah_name'],
                          'nomorSurah': item['surah_id'],
                        },
                      );
                      if (!mounted) return;
                      setState(() => _history = _db.getHistory());
                    },
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: 3,
          onTap: (index) => Navigator.pushReplacementNamed(
            context,
            ['/', '/quran', '/bookmark', '/history'][index],
          ),
        ),
      ),
    );
  }
}
